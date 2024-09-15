use crate::{
    prelude::*, PlRDataFrame, PlRDataType, PlRExpr, PlRLazyFrame, PlRLazyGroupBy, RPolarsErr,
};
use savvy::{savvy, ListSexp, LogicalSexp, OwnedStringSexp, Result, Sexp};

#[savvy]
impl PlRLazyFrame {
    fn describe_plan(&self) -> Result<Sexp> {
        let string = self.ldf.describe_plan().map_err(RPolarsErr::from)?;
        let sexp = OwnedStringSexp::try_from_scalar(string)?;
        Ok(sexp.into())
    }

    fn describe_optimized_plan(&self) -> Result<Sexp> {
        let string = self
            .ldf
            .describe_optimized_plan()
            .map_err(RPolarsErr::from)?;
        let sexp = OwnedStringSexp::try_from_scalar(string)?;
        Ok(sexp.into())
    }

    fn describe_plan_tree(&self) -> Result<Sexp> {
        let string = self.ldf.describe_plan_tree().map_err(RPolarsErr::from)?;
        let sexp = OwnedStringSexp::try_from_scalar(string)?;
        Ok(sexp.into())
    }

    fn describe_optimized_plan_tree(&self) -> Result<Sexp> {
        let string = self
            .ldf
            .describe_optimized_plan_tree()
            .map_err(RPolarsErr::from)?;
        let sexp = OwnedStringSexp::try_from_scalar(string)?;
        Ok(sexp.into())
    }

    fn optimization_toggle(
        &self,
        type_coercion: bool,
        predicate_pushdown: bool,
        projection_pushdown: bool,
        simplify_expression: bool,
        slice_pushdown: bool,
        comm_subplan_elim: bool,
        comm_subexpr_elim: bool,
        cluster_with_columns: bool,
        streaming: bool,
        _eager: bool,
    ) -> Result<Self> {
        let ldf = self
            .ldf
            .clone()
            .with_type_coercion(type_coercion)
            .with_predicate_pushdown(predicate_pushdown)
            .with_simplify_expr(simplify_expression)
            .with_slice_pushdown(slice_pushdown)
            .with_comm_subplan_elim(comm_subplan_elim)
            .with_comm_subexpr_elim(comm_subexpr_elim)
            .with_cluster_with_columns(cluster_with_columns)
            .with_streaming(streaming)
            ._with_eager(_eager)
            .with_projection_pushdown(projection_pushdown);

        Ok(ldf.into())
    }

    fn filter(&mut self, predicate: &PlRExpr) -> Result<Self> {
        let ldf = self.ldf.clone();
        Ok(ldf.filter(predicate.inner.clone()).into())
    }

    fn select(&mut self, exprs: ListSexp) -> Result<Self> {
        let ldf = self.ldf.clone();
        let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
        Ok(ldf.select(exprs).into())
    }

    fn group_by(&mut self, by: ListSexp, maintain_order: bool) -> Result<PlRLazyGroupBy> {
        let ldf = self.ldf.clone();
        let by = <Wrap<Vec<Expr>>>::from(by).0;
        let lazy_gb = if maintain_order {
            ldf.group_by_stable(by)
        } else {
            ldf.group_by(by)
        };

        Ok(lazy_gb.into())
    }

    fn collect(&self) -> Result<PlRDataFrame> {
        let df = self.ldf.clone().collect().map_err(RPolarsErr::from)?;
        Ok(df.into())
    }

    fn drop(&self, columns: ListSexp, strict: bool) -> Result<Self> {
        let ldf = self.ldf.clone();
        let columns = <Wrap<Vec<Expr>>>::from(columns).0;
        if strict {
            Ok(ldf.drop(columns).into())
        } else {
            Ok(ldf.drop_no_validate(columns).into())
        }
    }

    fn cast(&self, dtypes: ListSexp, strict: bool) -> Result<Self> {
        let dtypes = <Wrap<Vec<Field>>>::try_from(dtypes)?.0;
        let mut cast_map = PlHashMap::with_capacity(dtypes.len());
        cast_map.extend(dtypes.iter().map(|f| (f.name.as_ref(), f.dtype.clone())));
        Ok(self.ldf.clone().cast(cast_map, strict).into())
    }

    fn cast_all(&self, dtype: &PlRDataType, strict: bool) -> Result<Self> {
        Ok(self.ldf.clone().cast_all(dtype.dt.clone(), strict).into())
    }

    fn sort_by_exprs(
        &self,
        by: ListSexp,
        descending: LogicalSexp,
        nulls_last: LogicalSexp,
        maintain_order: bool,
        multithreaded: bool,
    ) -> Result<Self> {
        let ldf = self.ldf.clone();
        let by = <Wrap<Vec<Expr>>>::from(by).0;
        Ok(ldf
            .sort_by_exprs(
                by,
                SortMultipleOptions {
                    descending: descending.to_vec(),
                    nulls_last: nulls_last.to_vec(),
                    maintain_order,
                    multithreaded,
                },
            )
            .into())
    }

    fn with_columns(&mut self, exprs: ListSexp) -> Result<Self> {
        let ldf = self.ldf.clone();
        let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
        Ok(ldf.with_columns(exprs).into())
    }
}
