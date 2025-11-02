use super::PlROptFlags;
use parking_lot::RwLock;
use polars::prelude::OptFlags;

impl PlROptFlags {
    pub fn empty() -> Self {
        Self {
            inner: RwLock::new(OptFlags::empty()),
        }
    }

    #[allow(clippy::should_implement_trait)]
    pub fn default() -> Self {
        Self {
            inner: RwLock::default(),
        }
    }

    pub fn copy(&self) -> Self {
        Self {
            inner: RwLock::new(*self.inner.read()),
        }
    }

    pub fn set_projection_pushdown(&self, value: bool) {
        self.inner.write().set(OptFlags::PROJECTION_PUSHDOWN, value);
    }

    pub fn set_predicate_pushdown(&self, value: bool) {
        self.inner.write().set(OptFlags::PREDICATE_PUSHDOWN, value);
    }

    pub fn set_cluster_with_columns(&self, value: bool) {
        self.inner
            .write()
            .set(OptFlags::CLUSTER_WITH_COLUMNS, value);
    }

    pub fn set_simplify_expression(&self, value: bool) {
        self.inner.write().set(OptFlags::SIMPLIFY_EXPR, value);
    }

    pub fn set_slice_pushdown(&self, value: bool) {
        self.inner.write().set(OptFlags::SLICE_PUSHDOWN, value);
    }

    pub fn set_comm_subplan_elim(&self, value: bool) {
        self.inner.write().set(OptFlags::COMM_SUBPLAN_ELIM, value);
    }

    pub fn set_comm_subexpr_elim(&self, value: bool) {
        self.inner.write().set(OptFlags::COMM_SUBEXPR_ELIM, value);
    }

    pub fn set_type_coercion(&self, value: bool) {
        self.inner.write().set(OptFlags::TYPE_COERCION, value);
    }
}
