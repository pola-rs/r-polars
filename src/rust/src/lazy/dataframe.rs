use crate::conversion::strings_to_smartstrings;
use crate::rdataframe::DataFrame as RDataFrame;

use crate::concurrent::{collect_with_r_func_support, profile_with_r_func_support};
use crate::lazy::dsl::*;
use crate::rdataframe::DataFrame as RDF;

use crate::rdatatype::new_join_type;
use crate::rdatatype::new_quantile_interpolation_option;
use crate::rdatatype::new_unique_keep_strategy;
use crate::rdatatype::{new_asof_strategy, RPolarsDataType};
use crate::robj_to;
use crate::rpolarserr::{rerr, RResult, Rctx, WithRctx};
use crate::utils::wrappers::null_to_opt;
use crate::utils::{r_result_list, try_f64_into_usize};
use extendr_api::prelude::*;
use polars::chunked_array::object::AsOfOptions;
use polars::frame::explode::MeltArgs;
use polars::frame::hash_join::JoinType;
use polars::prelude as pl;

#[allow(unused_imports)]
use std::result::Result;

#[derive(Clone)]
pub struct LazyFrame(pub pl::LazyFrame);

impl std::fmt::Debug for LazyFrame {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "LazyFrame:")
    }
}

impl From<pl::LazyFrame> for LazyFrame {
    fn from(item: pl::LazyFrame) -> Self {
        LazyFrame(item)
    }
}

#[extendr]
impl LazyFrame {
    fn print(&self) -> Self {
        rprintln!("{}", self.0.describe_plan());
        self.clone()
    }

    pub fn describe_plan(&self) {
        rprintln!("{}", self.0.describe_plan());
    }

    //low level version of describe_plan, mainly for arg testing
    pub fn debug_plan(&self) -> Result<String, String> {
        use polars_core::export::serde::Serialize;
        use serde_json::value::Serializer;
        Serialize::serialize(&self.0.logical_plan.clone(), Serializer)
            .map_err(|err| err.to_string())
            .map(|val| format!("{:?}", val))
    }

    pub fn describe_optimized_plan(&self) -> List {
        let result = self.0.describe_optimized_plan().map(|opt_plan| {
            rprintln!("{}", opt_plan);
        });
        r_result_list(result.map_err(|err| format!("{:?}", err)))
    }

    pub fn collect(&self) -> RResult<RDF> {
        collect_with_r_func_support(self.clone().0)
    }

    pub fn collect_in_background(&self) -> crate::rbackground::RThreadHandle<RResult<RDataFrame>> {
        use crate::rbackground::*;
        let dup = self.clone();
        RThreadHandle::new(move || {
            Ok(RDataFrame::from(
                dup.0
                    .collect()
                    .map_err(crate::rpolarserr::polars_to_rpolars_err)?,
            ))
        })
    }

    fn first(&self) -> Self {
        self.0.clone().first().into()
    }

    fn last(&self) -> Self {
        self.0.clone().last().into()
    }

    fn max(&self) -> Self {
        self.0.clone().max().into()
    }

    fn min(&self) -> Self {
        self.0.clone().min().into()
    }

    fn mean(&self) -> Self {
        self.0.clone().mean().into()
    }

    fn median(&self) -> Self {
        self.0.clone().median().into()
    }

    fn sum(&self) -> Self {
        self.0.clone().sum().into()
    }

    pub fn std(&self, ddof: Robj) -> Result<Self, String> {
        Ok(self.clone().0.std(robj_to!(u8, ddof)?).into())
    }

    pub fn var(&self, ddof: Robj) -> Result<Self, String> {
        Ok(self.clone().0.var(robj_to!(u8, ddof)?).into())
    }

    pub fn quantile(&self, quantile: Robj, interpolation: Robj) -> Result<Self, String> {
        let res = new_quantile_interpolation_option(robj_to!(str, interpolation)?).unwrap();
        Ok(self
            .clone()
            .0
            .quantile(robj_to!(Expr, quantile)?.0, res)
            .into())
    }

    fn shift(&self, periods: Robj) -> Result<Self, String> {
        Ok(self.clone().0.shift(robj_to!(i64, periods)?).into())
    }

    fn shift_and_fill(&self, fill_value: Robj, periods: Robj) -> Result<Self, String> {
        Ok(self
            .clone()
            .0
            .shift_and_fill(robj_to!(i64, periods)?, robj_to!(Expr, fill_value)?.0)
            .into())
    }

    fn reverse(&self) -> Self {
        self.0.clone().reverse().into()
    }

    fn drop(&self, columns: Robj) -> Result<LazyFrame, String> {
        Ok(self
            .0
            .clone()
            .drop_columns(robj_to!(Vec, String, columns)?)
            .into())
    }

    fn fill_nan(&self, fill_value: Robj) -> Result<Self, String> {
        Ok(self
            .0
            .clone()
            .fill_nan(robj_to!(Expr, fill_value)?.0)
            .into())
    }

    fn fill_null(&self, fill_value: Robj) -> Result<Self, String> {
        Ok(self
            .0
            .clone()
            .fill_null(robj_to!(Expr, fill_value)?.0)
            .into())
    }

    fn slice(&self, offset: Robj, length: Robj) -> Result<LazyFrame, String> {
        Ok(LazyFrame(self.0.clone().slice(
            robj_to!(i64, offset)?,
            robj_to!(Option, u32, length)?.unwrap_or(u32::MAX),
        )))
    }

    pub fn select(&self, exprs: Robj) -> RResult<Self> {
        let exprs = robj_to!(VecPLExprCol, exprs).when("preparing expressions before select")?;
        Ok(LazyFrame(self.clone().0.select(exprs)))
    }

    fn limit(&self, n: Robj) -> Result<Self, String> {
        Ok(self.0.clone().limit(robj_to!(u32, n)?).into())
    }

    fn tail(&self, n: Robj) -> Result<LazyFrame, String> {
        Ok(LazyFrame(self.0.clone().tail(robj_to!(u32, n)?)))
    }

    fn filter(&self, expr: &Expr) -> LazyFrame {
        let new_df = self.clone().0.filter(expr.0.clone());
        LazyFrame(new_df)
    }

    fn drop_nulls(&self, subset: &ProtoExprArray) -> LazyFrame {
        if subset.0.is_empty() {
            LazyFrame(self.0.clone().drop_nulls(None))
        } else {
            let vec = pra_to_vec(subset, "select");
            LazyFrame(self.0.clone().drop_nulls(Some(vec)))
        }
    }

    fn unique(&self, subset: Robj, keep: Robj, maintain_order: Robj) -> Result<LazyFrame, String> {
        let ke = new_unique_keep_strategy(robj_to!(str, keep)?)?;
        let maintain_order = robj_to!(bool, maintain_order)?;
        let subset = robj_to!(Option, Vec, String, subset)?;
        let lf = if maintain_order {
            self.0.clone().unique_stable(subset, ke)
        } else {
            self.0.clone().unique(subset, ke)
        };
        Ok(lf.into())
    }

    fn groupby(&self, exprs: Robj, maintain_order: Robj) -> Result<LazyGroupBy, String> {
        let expr_vec = robj_to!(VecPLExprCol, exprs)?;
        let maintain_order = robj_to!(Option, bool, maintain_order)?.unwrap_or(false);
        if maintain_order {
            Ok(LazyGroupBy(self.0.clone().groupby_stable(expr_vec)))
        } else {
            Ok(LazyGroupBy(self.0.clone().groupby(expr_vec)))
        }
    }

    fn with_columns(&self, exprs: &ProtoExprArray) -> LazyFrame {
        LazyFrame(self.0.clone().with_columns(pra_to_vec(exprs, "select")))
    }

    fn with_column(&self, expr: &Expr) -> LazyFrame {
        R!("warning('`with_column()` is deprecated and will be removed in polars 0.9.0. Please use `with_columns()` instead.')")
        .expect("warning will not fail");
        LazyFrame(self.0.clone().with_column(expr.0.clone()))
    }

    fn with_row_count(&self, name: Robj, offset: Robj) -> RResult<Self> {
        Ok(self
            .0
            .clone()
            .with_row_count(
                robj_to!(String, name)?.as_str(),
                robj_to!(Option, u32, offset)?,
            )
            .into())
    }

    #[allow(clippy::too_many_arguments)]
    pub fn join_asof(
        &self,
        other: Robj,
        left_on: Robj,
        right_on: Robj,
        left_by: Nullable<Robj>,
        right_by: Nullable<Robj>,
        allow_parallel: Robj,
        force_parallel: Robj,
        suffix: Robj,
        strategy: Robj,
        tolerance: Robj,
        tolerance_str: Robj,
    ) -> Result<Self, String> {
        //TODO upgrade robj_to to handle variadic composed types, as
        // robj_to!(Option, Vec, left_by), instead of this ad-hoc conversion
        // using Nullable to handle outer Option and robj_to! for inner Vec<String>
        let left_by = null_to_opt(left_by)
            .map(|left_by| robj_to!(Vec, String, left_by))
            .transpose()?;
        let right_by = null_to_opt(right_by)
            .map(|right_by| robj_to!(Vec, String, right_by))
            .transpose()?;

        // polars AnyValue<&str> is not self owned, therefore rust-polars
        // chose to handle tolerance_str isolated as a String. Only one, if any,
        // of tolerance and tolerance_str is ecpected to be Some<T> and not None.
        // R might lack types to express any AnyValue. Using Expr allows for casting
        // like tolerance = pl$lit(42)$cast(pl$UInt64).

        let tolerance = robj_to!(Option, Expr, tolerance)?
            .map(|e| crate::rdatatype::expr_to_any_value(e.0))
            .transpose()?;
        let tolerance_str = robj_to!(Option, String, tolerance_str)?;

        Ok(self
            .0
            .clone()
            .join_builder()
            .with(robj_to!(LazyFrame, other)?.0)
            .left_on([robj_to!(ExprCol, left_on)?.0])
            .right_on([robj_to!(ExprCol, right_on)?.0])
            .allow_parallel(robj_to!(bool, allow_parallel)?)
            .force_parallel(robj_to!(bool, force_parallel)?)
            .how(JoinType::AsOf(AsOfOptions {
                strategy: robj_to!(str, strategy).and_then(|s| {
                    new_asof_strategy(s)
                        .map_err(Rctx::Plain)
                        .bad_arg("stragegy")
                })?,
                left_by: left_by.map(|opt_vec_s| opt_vec_s.into_iter().map(|s| s.into()).collect()),
                right_by: right_by
                    .map(|opt_vec_s| opt_vec_s.into_iter().map(|s| s.into()).collect()),
                tolerance,
                tolerance_str: tolerance_str.map(|s| s.into()),
            }))
            .suffix(robj_to!(str, suffix)?)
            .finish()
            .into())
    }

    #[allow(clippy::too_many_arguments)]
    fn join(
        &self,
        other: &LazyFrame,
        left_on: &ProtoExprArray,
        right_on: &ProtoExprArray,
        how: &str,
        suffix: &str,
        allow_parallel: bool,
        force_parallel: bool,
    ) -> LazyFrame {
        let ldf = self.0.clone();
        let other = other.0.clone();
        let left_on = pra_to_vec(left_on, "select");
        let right_on = pra_to_vec(right_on, "select");
        let how = new_join_type(how);

        LazyFrame(
            ldf.join_builder()
                .with(other)
                .left_on(left_on)
                .right_on(right_on)
                .allow_parallel(allow_parallel)
                .force_parallel(force_parallel)
                .how(how)
                .suffix(suffix)
                .finish(),
        )
    }

    pub fn sort_by_exprs(
        &self,
        by: Robj,
        descending: Robj,
        nulls_last: Robj,
    ) -> Result<Self, String> {
        let ldf = self.0.clone();
        let exprs = robj_to!(VecPLExpr, by).map_err(|err| format!("the arg [...] or {}", err))?;
        let descending = robj_to!(Vec, bool, descending)?;
        let nulls_last = robj_to!(bool, nulls_last)?;
        Ok(ldf.sort_by_exprs(exprs, descending, nulls_last).into())
    }

    fn melt(
        &self,
        id_vars: Robj,
        value_vars: Robj,
        value_name: Robj,
        variable_name: Robj,
        streamable: Robj,
    ) -> Result<Self, String> {
        let args = MeltArgs {
            id_vars: strings_to_smartstrings(robj_to!(Vec, String, id_vars)?),
            value_vars: strings_to_smartstrings(robj_to!(Vec, String, value_vars)?),
            value_name: robj_to!(Option, String, value_name)?.map(|s| s.into()),
            variable_name: robj_to!(Option, String, variable_name)?.map(|s| s.into()),
            streamable: robj_to!(bool, streamable)?,
        };
        Ok(self.0.clone().melt(args).into())
    }

    fn rename(&self, existing: Robj, new: Robj) -> Result<LazyFrame, String> {
        Ok(self
            .0
            .clone()
            .rename(
                robj_to!(Vec, String, existing)?,
                robj_to!(Vec, String, new)?,
            )
            .into())
    }

    fn schema(&self) -> RResult<Pairlist> {
        let schema = self
            .0
            .schema()
            .map_err(crate::rpolarserr::polars_to_rpolars_err)?;
        let pairs = schema.iter().collect::<Vec<_>>().into_iter();
        Ok(Pairlist::from_pairs(
            pairs.map(|(name, ty)| (name, RPolarsDataType(ty.clone()))),
        ))
    }

    #[allow(clippy::too_many_arguments)]
    fn optimization_toggle(
        &self,
        type_coercion: Robj,
        predicate_pushdown: Robj,
        projection_pushdown: Robj,
        simplify_expr: Robj,
        slice_pushdown: Robj,
        cse: Robj,
        streaming: Robj,
    ) -> RResult<Self> {
        let ldf = self
            .0
            .clone()
            .with_type_coercion(robj_to!(bool, type_coercion)?)
            .with_predicate_pushdown(robj_to!(bool, predicate_pushdown)?)
            .with_simplify_expr(robj_to!(bool, simplify_expr)?)
            .with_slice_pushdown(robj_to!(bool, slice_pushdown)?)
            .with_streaming(robj_to!(bool, streaming)?)
            .with_projection_pushdown(robj_to!(bool, projection_pushdown)?)
            .with_common_subplan_elimination(robj_to!(bool, cse)?);

        Ok(ldf.into())
    }

    fn profile(&self) -> RResult<List> {
        profile_with_r_func_support(self.0.clone()).map(|(r, p)| list!(result = r, profile = p))
    }

    fn explode(&self, dotdotdot_args: Robj) -> RResult<LazyFrame> {
        Ok(self
            .0
            .clone()
            .explode(robj_to!(Vec, PLExprCol, dotdotdot_args)?)
            .into())
    }

    pub fn clone_see_me_macro(&self) -> LazyFrame {
        self.clone()
    }
}

#[derive(Clone)]
pub struct LazyGroupBy(pub pl::LazyGroupBy);

#[extendr]
impl LazyGroupBy {
    fn print(&self) {
        rprintln!("LazyGroupBy (internals are opaque)");
    }

    fn agg(&self, exprs: Robj) -> Result<LazyFrame, String> {
        let expr_vec: Vec<pl::Expr> = robj_to!(VecPLExprCol, exprs)?;
        Ok(LazyFrame(self.0.clone().agg(expr_vec)))
    }

    fn head(&self, n: f64) -> List {
        r_result_list(
            try_f64_into_usize(n)
                .map(|n| LazyFrame(self.0.clone().head(Some(n))))
                .map_err(|err| format!("head: {}", err)),
        )
    }

    fn tail(&self, n: f64) -> List {
        r_result_list(
            try_f64_into_usize(n)
                .map(|n| LazyFrame(self.0.clone().tail(Some(n))))
                .map_err(|err| format!("tail: {}", err)),
        )
    }

    // fn apply(&self, robj: Robj, val: f64) -> Robj {
    //     todo!("not done");
    // }
}

extendr_module! {
    mod dataframe;
    impl LazyFrame;
    impl LazyGroupBy;
}
