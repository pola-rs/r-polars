use super::PlROptFlags;
use parking_lot::RwLock;
use polars::prelude::OptFlags;
use savvy::Result;

impl PlROptFlags {
    pub fn empty() -> Result<Self> {
        Ok(Self {
            inner: RwLock::new(OptFlags::empty()),
        })
    }

    #[allow(clippy::should_implement_trait)]
    pub fn default() -> Result<Self> {
        Ok(Self {
            inner: RwLock::default(),
        })
    }

    pub fn copy(&self) -> Result<Self> {
        Ok(Self {
            inner: RwLock::new(*self.inner.read()),
        })
    }

    pub fn set_projection_pushdown(&self, value: bool) -> Result<()> {
        self.inner.write().set(OptFlags::PROJECTION_PUSHDOWN, value);
        Ok(())
    }

    pub fn set_predicate_pushdown(&self, value: bool) -> Result<()> {
        self.inner.write().set(OptFlags::PREDICATE_PUSHDOWN, value);
        Ok(())
    }

    pub fn set_cluster_with_columns(&self, value: bool) -> Result<()> {
        self.inner
            .write()
            .set(OptFlags::CLUSTER_WITH_COLUMNS, value);
        Ok(())
    }

    pub fn set_simplify_expression(&self, value: bool) -> Result<()> {
        self.inner.write().set(OptFlags::SIMPLIFY_EXPR, value);
        Ok(())
    }

    pub fn set_slice_pushdown(&self, value: bool) -> Result<()> {
        self.inner.write().set(OptFlags::SLICE_PUSHDOWN, value);
        Ok(())
    }

    pub fn set_comm_subplan_elim(&self, value: bool) -> Result<()> {
        self.inner.write().set(OptFlags::COMM_SUBPLAN_ELIM, value);
        Ok(())
    }

    pub fn set_comm_subexpr_elim(&self, value: bool) -> Result<()> {
        self.inner.write().set(OptFlags::COMM_SUBEXPR_ELIM, value);
        Ok(())
    }

    pub fn set_check_order_observe(&self, value: bool) -> Result<()> {
        self.inner.write().set(OptFlags::CHECK_ORDER_OBSERVE, value);
        Ok(())
    }
}
