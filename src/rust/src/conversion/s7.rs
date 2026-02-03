use crate::{lazyframe::PlROptFlags, prelude::*};
use savvy::{ObjSexp, Sexp, savvy_err};

// Get the S7 class name from an object.
// In R: `attr(obj, "S7_class") |> attr("name")`
fn get_s7_class_name(obj: &ObjSexp) -> Option<String> {
    obj.get_attrib("S7_class")
        .ok()
        .flatten()
        .and_then(|s7_class| {
            s7_class
                .get_attrib("name")
                .ok()
                .flatten()
                .and_then(|name_sexp| <&str>::try_from(name_sexp).ok())
                .map(|s| s.to_string())
        })
}

// TODO: Move this to upstream?
pub(crate) fn try_extract_prop<T>(obj: &ObjSexp, attr_name: &str) -> savvy::Result<T>
where
    T: TryFrom<Sexp, Error = savvy::Error>,
{
    obj.get_attrib(attr_name)?
        .ok_or(savvy_err!("Attribute '{attr_name}' does not exist."))
        .and_then(|v| T::try_from(v))
}

pub(crate) fn try_extract_opt_prop<T>(obj: &ObjSexp, attr_name: &str) -> savvy::Result<Option<T>>
where
    T: TryFrom<Sexp, Error = savvy::Error>,
{
    obj.get_attrib(attr_name)?
        .map_or(Ok(None), |v| Ok(Some(T::try_from(v)?)))
}

impl TryFrom<ObjSexp> for PlROptFlags {
    type Error = savvy::Error;

    fn try_from(obj: ObjSexp) -> Result<Self, savvy::Error> {
        let opts = PlROptFlags::empty();

        const ATTR_NAMES: &[&str] = &[
            "type_coercion",
            "type_check",
            "predicate_pushdown",
            "projection_pushdown",
            "simplify_expression",
            "slice_pushdown",
            "comm_subplan_elim",
            "comm_subexpr_elim",
            "cluster_with_columns",
            "check_order_observe",
            "fast_projection",
            "eager",
            "streaming",
        ];

        for &attr_name in ATTR_NAMES {
            let attr_value: bool = try_extract_prop(&obj, attr_name)?;

            match attr_name {
                "type_coercion" => opts.set_type_coercion(attr_value),
                "type_check" => opts.set_type_check(attr_value),
                "predicate_pushdown" => opts.set_predicate_pushdown(attr_value),
                "projection_pushdown" => opts.set_projection_pushdown(attr_value),
                "simplify_expression" => opts.set_simplify_expression(attr_value),
                "slice_pushdown" => opts.set_slice_pushdown(attr_value),
                "comm_subplan_elim" => opts.set_comm_subplan_elim(attr_value),
                "comm_subexpr_elim" => opts.set_comm_subexpr_elim(attr_value),
                "cluster_with_columns" => opts.set_cluster_with_columns(attr_value),
                "check_order_observe" => opts.set_check_order_observe(attr_value),
                "fast_projection" => opts.set_fast_projection(attr_value),
                "eager" => opts.set_eager(attr_value),
                "streaming" => opts.set_streaming(attr_value),
                _ => unreachable!(),
            }
        }
        Ok(opts)
    }
}

// Same as PyFileSinkDestination::extract_file_sink_destination
impl TryFrom<ObjSexp> for Wrap<SinkDestination> {
    type Error = savvy::Error;

    fn try_from(obj: ObjSexp) -> Result<Self, savvy::Error> {
        let class_name = get_s7_class_name(&obj);

        // Check if this is the new PartitionBy class or legacy SinkDirectory-based classes
        if class_name.as_deref() == Some("PartitionBy") {
            extract_partition_by(&obj)
        } else {
            // TODO: remove legacy support later
            extract_sink_directory(&obj)
        }
    }
}

fn extract_partition_by(obj: &ObjSexp) -> savvy::Result<Wrap<SinkDestination>> {
    let base_path: &str = try_extract_prop(obj, "base_path")?;
    let key: Option<Wrap<Vec<Expr>>> = try_extract_opt_prop(obj, "key")?;
    let include_key: Option<bool> = try_extract_opt_prop(obj, "include_key")?;
    let max_rows_per_file: Option<Wrap<u32>> = try_extract_opt_prop(obj, "max_rows_per_file")?;
    let approximate_bytes_per_file: Option<Wrap<u64>> =
        try_extract_opt_prop(obj, "approximate_bytes_per_file")?;

    let partition_strategy: PartitionStrategy = if let Some(key) = &key {
        PartitionStrategy::Keyed {
            keys: key.0.clone(),
            include_keys: include_key.unwrap_or(true),
            keys_pre_grouped: false,
        }
    } else {
        PartitionStrategy::FileSize
    };

    Ok(Wrap(SinkDestination::Partitioned {
        base_path: PlRefPath::new(base_path),
        file_path_provider: None,
        partition_strategy,
        max_rows_per_file: max_rows_per_file.map(|wrap| wrap.0).unwrap_or(IdxSize::MAX),
        approximate_bytes_per_file: approximate_bytes_per_file
            .map(|wrap| wrap.0)
            .unwrap_or(u64::MAX),
    }))
}

/// Extract from legacy SinkDirectory-based classes (PartitionMaxSize, PartitionByKey, PartitionParted)
fn extract_sink_directory(obj: &ObjSexp) -> savvy::Result<Wrap<SinkDestination>> {
    let base_path: &str = try_extract_prop(obj, "base_path")?;
    let partition_by: Option<Wrap<Vec<Expr>>> = try_extract_opt_prop(obj, "partition_by")?;
    let partition_keys_sorted: Option<bool> = try_extract_opt_prop(obj, "partition_keys_sorted")?;
    let include_keys: Option<bool> = try_extract_opt_prop(obj, "include_keys")?;
    let per_partition_sort_by: Option<Wrap<Vec<Expr>>> =
        try_extract_opt_prop(obj, "per_partition_sort_by")?;
    let per_file_sort_by: Option<Wrap<Vec<Expr>>> = try_extract_opt_prop(obj, "per_file_sort_by")?;
    let max_rows_per_file: Option<Wrap<u32>> = try_extract_opt_prop(obj, "max_rows_per_file")?;

    if per_partition_sort_by.is_some() && per_file_sort_by.is_some() {
        return Err(savvy_err!(
            "cannot specify both `per_partition_sort_by` and `per_file_sort_by`"
        ));
    }

    let partition_strategy: PartitionStrategy = if let Some(partition_by) = &partition_by {
        if per_file_sort_by.is_some() {
            return Err(savvy_err!(
                "unimplemented: `per_file_sort_by` with `partition_by`"
            ));
        }

        PartitionStrategy::Keyed {
            keys: partition_by.0.clone(),
            include_keys: include_keys.unwrap_or(true),
            keys_pre_grouped: partition_keys_sorted.unwrap_or(false),
        }
    } else if let Some(parameter_name) = partition_keys_sorted
        .is_some()
        .then_some("partition_keys_sorted")
        .or(include_keys.is_some().then_some("include_keys"))
        .or(per_partition_sort_by
            .is_some()
            .then_some("per_partition_sort_by"))
    {
        return Err(savvy_err!(
            "cannot use `{parameter_name}` without specifying `partition_by`"
        ));
    } else if max_rows_per_file.is_some() {
        PartitionStrategy::FileSize
    } else {
        return Err(savvy_err!(
            "at least one of (`partition_by`, `max_rows_per_file`) \
             must be specified for SinkPartitioned",
        ));
    };

    Ok(Wrap(SinkDestination::Partitioned {
        base_path: PlRefPath::new(base_path),
        file_path_provider: None,
        partition_strategy,
        max_rows_per_file: max_rows_per_file.map(|wrap| wrap.0).unwrap_or(IdxSize::MAX),
        // Legacy classes don't support approximate_bytes_per_file
        approximate_bytes_per_file: u64::MAX,
    }))
}
