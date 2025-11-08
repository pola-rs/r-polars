use crate::lazyframe::PlROptFlags;
use savvy::{Sexp, TypedSexp};

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

        ATTR_NAMES.iter().for_each(|attr_name| {
            // Safety: validated on the R side
            let attr_value = match obj.get_attrib(attr_name).unwrap().unwrap().into_typed() {
                TypedSexp::Logical(l) => l.iter().next().unwrap(),
                _ => unreachable!(),
            };
            match *attr_name {
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
        });
        Ok(opts)
    }
}
