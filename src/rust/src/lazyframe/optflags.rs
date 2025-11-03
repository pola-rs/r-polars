use super::PlROptFlags;
use parking_lot::RwLock;
use polars::prelude::OptFlags;

impl PlROptFlags {
    pub fn empty() -> Self {
        Self {
            inner: RwLock::new(OptFlags::empty()),
        }
    }
}

macro_rules! flag_setters {
    ($(($flag:ident, $setter:ident))+) => {
        impl PlROptFlags {
            $(
            pub fn $setter(&self, value: bool) {
                self.inner.write().set(OptFlags::$flag, value)
            }
            )+
        }
    };
}

flag_setters! {
    (TYPE_COERCION, set_type_coercion)
    (TYPE_CHECK, set_type_check)

    (PROJECTION_PUSHDOWN, set_projection_pushdown)
    (PREDICATE_PUSHDOWN, set_predicate_pushdown)
    (CLUSTER_WITH_COLUMNS, set_cluster_with_columns)
    (SIMPLIFY_EXPR, set_simplify_expression)
    (SLICE_PUSHDOWN, set_slice_pushdown)
    (COMM_SUBPLAN_ELIM, set_comm_subplan_elim)
    (COMM_SUBEXPR_ELIM, set_comm_subexpr_elim)
    (CHECK_ORDER_OBSERVE, set_check_order_observe)
    (FAST_PROJECTION, set_fast_projection)

    (EAGER, set_eager)
    (NEW_STREAMING, set_streaming)
}
