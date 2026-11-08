use super::s7_api;
use crate::{lazyframe::PlROptFlags, prelude::*};
use savvy::{ObjSexp, Sexp, savvy_err};

// Extract a required property of an S7 object.
//
// `T` must not borrow from the property value (e.g. `&str`), because the value
// is not protected after this function returns. Use `try_extract_string_prop()`
// for strings.
// TODO: Move this to upstream?
pub(crate) fn try_extract_prop<T>(obj: &ObjSexp, prop_name: &str) -> savvy::Result<T>
where
    T: TryFrom<Sexp, Error = savvy::Error>,
{
    let value = s7_api::prop(obj, prop_name)?
        .ok_or_else(|| savvy_err!("Property '{prop_name}' does not exist or is NULL."))?;
    T::try_from(value.sexp())
}

// Extract an optional property of an S7 object. `NULL` is converted to `None`.
// The same restriction on `T` as `try_extract_prop()` applies.
pub(crate) fn try_extract_opt_prop<T>(obj: &ObjSexp, prop_name: &str) -> savvy::Result<Option<T>>
where
    T: TryFrom<Sexp, Error = savvy::Error>,
{
    match s7_api::prop(obj, prop_name)? {
        Some(value) => Ok(Some(T::try_from(value.sexp())?)),
        None => Ok(None),
    }
}

// Extract a required string property of an S7 object. The string is copied
// while the property value is still protected.
pub(crate) fn try_extract_string_prop(obj: &ObjSexp, prop_name: &str) -> savvy::Result<String> {
    let value = s7_api::prop(obj, prop_name)?
        .ok_or_else(|| savvy_err!("Property '{prop_name}' does not exist or is NULL."))?;
    let string: &str = value.sexp().try_into()?;
    Ok(string.to_string())
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
            "join_order",
            "row_estimate",
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
                "join_order" => opts.set_join_order(attr_value),
                "row_estimate" => opts.set_row_estimate(attr_value),
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
        match s7_api::class_info(&obj)? {
            // Check the package as well to avoid confusion with a class of the
            // same name defined by another package.
            Some(class)
                if class.name == "PartitionBy" && class.package.as_deref() == Some("polars") =>
            {
                extract_partition_by(&obj)
            }
            _ => Err(savvy_err!("expected a PartitionBy object")),
        }
    }
}

fn extract_partition_by(obj: &ObjSexp) -> savvy::Result<Wrap<SinkDestination>> {
    let base_path = try_extract_string_prop(obj, "base_path")?;
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
        base_path: PlRefPath::new(base_path.as_str()),
        file_path_provider: None,
        partition_strategy,
        max_rows_per_file: max_rows_per_file.map(|wrap| wrap.0).unwrap_or(IdxSize::MAX),
        approximate_bytes_per_file: approximate_bytes_per_file
            .map(|wrap| wrap.0)
            .unwrap_or(u64::MAX),
    }))
}
