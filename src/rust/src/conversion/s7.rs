use super::try_extract_attribute;
use crate::{lazyframe::PlROptFlags, prelude::*};
use savvy::{Sexp, savvy_err};

impl TryFrom<Sexp> for PlROptFlags {
    type Error = savvy::Error;

    fn try_from(obj: Sexp) -> Result<Self, savvy::Error> {
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
            let attr_value: bool = try_extract_attribute(&obj, attr_name)?;

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
impl TryFrom<Sexp> for Wrap<SinkDestination> {
    type Error = savvy::Error;

    fn try_from(obj: Sexp) -> Result<Self, savvy::Error> {
        // Special case for single string, not an S7 object
        // Workaround for savvy does not support ObjSexp
        if obj.is_string() {
            let path: &str = obj.try_into()?;
            let target = <Wrap<SinkDestination>>::try_from(path)?.0;
            return Ok(Wrap(target));
        }

        let base_path: &str = try_extract_attribute(&obj, "base_path")?;
        let partition_by: Option<Wrap<Vec<Expr>>> =
            try_extract_opt_attribute(&obj, "partition_by")?;
        let partition_keys_sorted: Option<bool> =
            try_extract_opt_attribute(&obj, "partition_keys_sorted")?;
        let include_keys: Option<bool> = try_extract_opt_attribute(&obj, "include_keys")?;
        let per_partition_sort_by: Option<Wrap<Vec<Expr>>> =
            try_extract_opt_attribute(&obj, "per_partition_sort_by")?;
        let per_file_sort_by: Option<Wrap<Vec<Expr>>> =
            try_extract_opt_attribute(&obj, "per_file_sort_by")?;
        let max_rows_per_file: Option<Wrap<u32>> =
            try_extract_opt_attribute(&obj, "max_rows_per_file")?;

        if per_partition_sort_by.is_some() && per_file_sort_by.is_some() {
            return Err(savvy_err!(
                "cannot specify both `per_partition_sort_by` and `per_file_sort_by`"
            ));
        }

        let partition_strategy: PartitionStrategy = if let Some(partition_by) = &partition_by {
            if max_rows_per_file.is_some() {
                return Err(savvy_err!(
                    "unimplemented: `max_rows_per_file` with `partition_by`"
                ));
            }

            if per_file_sort_by.is_some() {
                return Err(savvy_err!(
                    "unimplemented: `per_file_sort_by` with `partition_by`"
                ));
            }

            PartitionStrategy::Keyed {
                keys: partition_by.0.clone(),
                include_keys: include_keys.unwrap_or(true),
                keys_pre_grouped: partition_keys_sorted.unwrap_or(false),
                per_partition_sort_by: per_partition_sort_by
                    .map(|wrap| wrap.0)
                    .unwrap_or_default()
                    .into_iter()
                    .map(|x| SortColumn {
                        expr: x,
                        descending: false,
                        nulls_last: false,
                    })
                    .collect(),
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
            base_path: PlPath::new(base_path),
            file_path_provider: None,
            partition_strategy,
            finish_callback: None,
            max_rows_per_file: max_rows_per_file.map(|wrap| wrap.0).unwrap_or(IdxSize::MAX),
            approximate_bytes_per_file: u64::MAX,
        }))
    }
}
