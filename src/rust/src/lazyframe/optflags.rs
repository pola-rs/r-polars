use super::PlROptFlags;
use parking_lot::RwLock;
use polars::prelude::OptFlags;
use savvy::{Result, Sexp, savvy};

#[savvy]
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
            inner: RwLock::new(self.inner.read().clone()),
        })
    }

    // Type coercion flags
    fn get_type_coercion(&self) -> Result<Sexp> {
        self.inner
            .read()
            .contains(OptFlags::TYPE_COERCION)
            .try_into()
    }

    fn set_type_coercion(&self, value: bool) -> Result<()> {
        let _ = self.inner.write().set(OptFlags::TYPE_COERCION, value);
        Ok(())
    }

    // Type check flags
    fn get_type_check(&self) -> Result<Sexp> {
        self.inner.read().contains(OptFlags::TYPE_CHECK).try_into()
    }

    fn set_type_check(&self, value: bool) -> Result<()> {
        let _ = self.inner.write().set(OptFlags::TYPE_CHECK, value);
        Ok(())
    }

    // Projection pushdown flags
    fn get_projection_pushdown(&self) -> Result<Sexp> {
        self.inner
            .read()
            .contains(OptFlags::PROJECTION_PUSHDOWN)
            .try_into()
    }

    fn set_projection_pushdown(&self, value: bool) -> Result<()> {
        let _ = self.inner.write().set(OptFlags::PROJECTION_PUSHDOWN, value);
        Ok(())
    }

    // Predicate pushdown flags
    fn get_predicate_pushdown(&self) -> Result<Sexp> {
        self.inner
            .read()
            .contains(OptFlags::PREDICATE_PUSHDOWN)
            .try_into()
    }

    fn set_predicate_pushdown(&self, value: bool) -> Result<()> {
        let _ = self.inner.write().set(OptFlags::PREDICATE_PUSHDOWN, value);
        Ok(())
    }

    // Cluster with columns flags
    fn get_cluster_with_columns(&self) -> Result<Sexp> {
        self.inner
            .read()
            .contains(OptFlags::CLUSTER_WITH_COLUMNS)
            .try_into()
    }

    fn set_cluster_with_columns(&self, value: bool) -> Result<()> {
        let _ = self
            .inner
            .write()
            .set(OptFlags::CLUSTER_WITH_COLUMNS, value);
        Ok(())
    }

    // Simplify expression flags
    fn get_simplify_expression(&self) -> Result<Sexp> {
        self.inner
            .read()
            .contains(OptFlags::SIMPLIFY_EXPR)
            .try_into()
    }

    fn set_simplify_expression(&self, value: bool) -> Result<()> {
        let _ = self.inner.write().set(OptFlags::SIMPLIFY_EXPR, value);
        Ok(())
    }

    // Slice pushdown flags
    fn get_slice_pushdown(&self) -> Result<Sexp> {
        self.inner
            .read()
            .contains(OptFlags::SLICE_PUSHDOWN)
            .try_into()
    }

    fn set_slice_pushdown(&self, value: bool) -> Result<()> {
        let _ = self.inner.write().set(OptFlags::SLICE_PUSHDOWN, value);
        Ok(())
    }

    // Common subplan elimination flags
    fn get_comm_subplan_elim(&self) -> Result<Sexp> {
        self.inner
            .read()
            .contains(OptFlags::COMM_SUBPLAN_ELIM)
            .try_into()
    }

    fn set_comm_subplan_elim(&self, value: bool) -> Result<()> {
        let _ = self.inner.write().set(OptFlags::COMM_SUBPLAN_ELIM, value);
        Ok(())
    }

    // Common subexpression elimination flags
    fn get_comm_subexpr_elim(&self) -> Result<Sexp> {
        self.inner
            .read()
            .contains(OptFlags::COMM_SUBEXPR_ELIM)
            .try_into()
    }

    fn set_comm_subexpr_elim(&self, value: bool) -> Result<()> {
        let _ = self.inner.write().set(OptFlags::COMM_SUBEXPR_ELIM, value);
        Ok(())
    }

    // Check order observe flags
    fn get_check_order_observe(&self) -> Result<Sexp> {
        self.inner
            .read()
            .contains(OptFlags::CHECK_ORDER_OBSERVE)
            .try_into()
    }

    fn set_check_order_observe(&self, value: bool) -> Result<()> {
        let _ = self.inner.write().set(OptFlags::CHECK_ORDER_OBSERVE, value);
        Ok(())
    }

    // Fast projection flags
    fn get_fast_projection(&self) -> Result<Sexp> {
        self.inner
            .read()
            .contains(OptFlags::FAST_PROJECTION)
            .try_into()
    }

    fn set_fast_projection(&self, value: bool) -> Result<()> {
        let _ = self.inner.write().set(OptFlags::FAST_PROJECTION, value);
        Ok(())
    }

    // Eager flags
    fn get_eager(&self) -> Result<Sexp> {
        self.inner.read().contains(OptFlags::EAGER).try_into()
    }

    fn set_eager(&self, value: bool) -> Result<()> {
        let _ = self.inner.write().set(OptFlags::EAGER, value);
        Ok(())
    }

    // Streaming flags
    fn get_streaming(&self) -> Result<Sexp> {
        self.inner
            .read()
            .contains(OptFlags::NEW_STREAMING)
            .try_into()
    }

    fn set_streaming(&self, value: bool) -> Result<()> {
        let _ = self.inner.write().set(OptFlags::NEW_STREAMING, value);
        Ok(())
    }
}
