use crate::rdatatype::literal_to_any_value;
use crate::rdatatype::new_null_behavior;
use crate::rdatatype::new_quantile_interpolation_option;
use crate::rdatatype::new_rank_method;
use crate::rdatatype::robj_to_timeunit;
use crate::rdatatype::{DataTypeVector, RPolarsDataType};
use crate::robj_to;

use crate::rpolarserr;
use crate::rpolarserr::*;
use crate::series::Series;
use crate::utils::extendr_concurrent::{ParRObj, ThreadCom};
use crate::utils::parse_fill_null_strategy;
use crate::utils::wrappers::null_to_opt;
use crate::utils::{r_error_list, r_ok_list, r_result_list};
use crate::utils::{
    try_f64_into_i64, try_f64_into_u32, try_f64_into_usize, try_f64_into_usize_no_zero,
};
use crate::CONFIG;
use extendr_api::{extendr, prelude::*, rprintln, Deref, DerefMut, Rinternals};
use pl::PolarsError as pl_error;
use polars::chunked_array::object::SortOptions;
use polars::lazy::dsl;
use polars::prelude::BinaryNameSpaceImpl;
use polars::prelude::DurationMethods;
use polars::prelude::GetOutput;
use polars::prelude::IntoSeries;
use polars::prelude::TemporalMethods;
use polars::prelude::Utf8NameSpaceImpl;
use polars::prelude::{self as pl};
use std::ops::{Add, Div, Mul, Sub};
use std::result::Result;
pub type NameGenerator = pl::Arc<dyn Fn(usize) -> String + Send + Sync>;
#[derive(Clone, Debug)]
pub struct Expr(pub pl::Expr);

impl Deref for Expr {
    type Target = pl::Expr;
    fn deref(&self) -> &pl::Expr {
        &self.0
    }
}

impl DerefMut for Expr {
    fn deref_mut(&mut self) -> &mut pl::Expr {
        &mut self.0
    }
}

impl From<pl::Expr> for Expr {
    fn from(expr: pl::Expr) -> Self {
        Expr(expr)
    }
}

#[extendr]
impl Expr {
    //constructors
    pub fn col(name: &str) -> Self {
        dsl::col(name).into()
    }

    //via col
    pub fn dtype_cols(dtypes: &DataTypeVector) -> Self {
        dsl::dtype_cols(dtypes.dtv_to_vec()).into()
    }

    //via col
    pub fn cols(names: Vec<String>) -> Self {
        dsl::cols(names).into()
    }

    //TODO expand usecases to series and datatime
    pub fn lit(robj: Robj) -> RResult<Expr> {
        let rtype = robj.rtype();
        let rlen = robj.len();

        match (rtype, rlen) {
            (Rtype::Null, _) => Ok(dsl::lit(pl::NULL)),
            (Rtype::Integers, 1) => {
                let opt_val = robj.as_integer();
                if let Some(val) = opt_val {
                    Ok(dsl::lit(val))
                } else if robj.is_na() {
                    Ok(dsl::lit(pl::NULL).cast(pl::DataType::Int32))
                } else {
                    unreachable!("internal error: could unexpectedly not handle this R value");
                }
            }
            (Rtype::Doubles, 1) if robj.inherits("integer64") => {
                let opt_val = robj.as_real();
                if let Some(val) = opt_val {
                    let x = val.to_bits() as i64;
                    if x == crate::utils::BIT64_NA_ECODING {
                        Ok(dsl::lit(pl::NULL).cast(pl::DataType::Int64))
                    } else {
                        Ok(dsl::lit(x))
                    }
                } else {
                    unreachable!("internal error: could unexpectedly not handle this R value");
                }
            }
            (Rtype::Doubles, 1) => {
                let opt_val = robj.as_real();
                if let Some(val) = opt_val {
                    Ok(dsl::lit(val))
                } else if robj.is_na() {
                    Ok(dsl::lit(pl::NULL).cast(pl::DataType::Float64))
                } else {
                    unreachable!("internal error: could unexpectedly not handle this R value");
                }
            }
            (Rtype::Strings, 1) => {
                if robj.is_na() {
                    Ok(dsl::lit(pl::NULL).cast(pl::DataType::Utf8))
                } else {
                    Ok(dsl::lit(robj.as_str().unwrap()))
                }
            }
            (Rtype::Logicals, 1) => {
                let opt_val = robj.as_bool();
                if let Some(val) = opt_val {
                    Ok(dsl::lit(val))
                } else if robj.is_na() {
                    Ok(dsl::lit(pl::NULL).cast(pl::DataType::Boolean))
                } else {
                    unreachable!("internal error: could unexpectedly not handle this R value");
                }
            }
            (Rtype::ExternalPtr, 1) => match () {
                _ if robj.inherits("Series") => {
                    let s: Series = unsafe { &mut *robj.external_ptr_addr::<Series>() }.clone();
                    Ok(pl::lit(s.0))
                }
                _ => rerr()
                    .bad_robj(&robj)
                    .plain("pl$lit() currently only support ExternalPtr's to polars 'Series'"),
            },

            (_, 1) => rerr().bad_robj(&robj).plain("unsupported R type "),
            (_, n) => rerr()
                .bad_robj(&robj)
                .plain(format!("literals mush have length [1], not [{n}]")),
        }
        .map(Expr)
        .when("constructing polars literal from Robj")
    }

    //expr binary comparisons
    pub fn gt(&self, other: Robj) -> RResult<Self> {
        Ok(self.0.clone().gt(robj_to!(PLExpr, other)?).into())
    }

    pub fn gt_eq(&self, other: Robj) -> RResult<Self> {
        Ok(self.0.clone().gt_eq(robj_to!(PLExpr, other)?).into())
    }

    pub fn lt(&self, other: Robj) -> RResult<Self> {
        Ok(self.0.clone().lt(robj_to!(PLExpr, other)?).into())
    }

    pub fn lt_eq(&self, other: Robj) -> RResult<Self> {
        Ok(self.0.clone().lt_eq(robj_to!(PLExpr, other)?).into())
    }

    pub fn neq(&self, other: Robj) -> RResult<Self> {
        Ok(self.0.clone().neq(robj_to!(PLExpr, other)?).into())
    }

    pub fn eq(&self, other: Robj) -> RResult<Self> {
        Ok(self.0.clone().eq(robj_to!(PLExpr, other)?).into())
    }

    //logical operators
    fn and(&self, other: Robj) -> RResult<Self> {
        Ok(self.0.clone().and(robj_to!(PLExpr, other)?).into())
    }

    fn or(&self, other: Robj) -> RResult<Self> {
        Ok(self.0.clone().or(robj_to!(PLExpr, other)?).into())
    }

    fn xor(&self, other: Robj) -> RResult<Self> {
        Ok(self.0.clone().xor(robj_to!(PLExpr, other)?).into())
    }

    fn is_in(&self, other: Robj) -> RResult<Self> {
        Ok(self.0.clone().is_in(robj_to!(PLExpr, other)?).into())
    }

    //any not translated expr from expr/expr.py
    pub fn to_physical(&self) -> Self {
        self.0
            .clone()
            .map(
                |s| Ok(Some(s.to_physical_repr().into_owned())),
                GetOutput::map_dtype(|dt| dt.to_physical()),
            )
            .with_fmt("to_physical")
            .into()
    }

    pub fn cast(&self, data_type: &RPolarsDataType, strict: bool) -> Self {
        let dt = data_type.0.clone();
        if strict {
            self.0.clone().strict_cast(dt)
        } else {
            self.0.clone().cast(dt)
        }
        .into()
    }

    //TODO expoes multithreded arg
    pub fn sort(&self, descending: bool, nulls_last: bool) -> Self {
        self.clone()
            .0
            .sort_with(SortOptions {
                descending,
                nulls_last,
                multithreaded: false,
            })
            .into()
    }

    pub fn arg_sort(&self, descending: bool, nulls_last: bool) -> Self {
        self.clone()
            .0
            .arg_sort(SortOptions {
                descending,
                nulls_last,
                multithreaded: false,
            })
            .into()
    }

    pub fn top_k(&self, k: f64) -> Self {
        self.0.clone().top_k(k as usize).into()
    }

    pub fn bottom_k(&self, k: f64) -> Self {
        self.0.clone().bottom_k(k as usize).into()
    }

    pub fn arg_max(&self) -> Self {
        self.clone().0.arg_max().into()
    }
    pub fn arg_min(&self) -> Self {
        self.clone().0.arg_min().into()
    }

    //TODO expose searchSorted side options
    pub fn search_sorted(&self, element: &Expr) -> Self {
        use pl::SearchSortedSide as Side;
        self.0
            .clone()
            .search_sorted(element.0.clone(), Side::Any)
            .into()
    }

    pub fn take(&self, idx: &Expr) -> Self {
        self.clone().0.take(idx.0.clone()).into()
    }

    pub fn sort_by(&self, by: Robj, descending: Robj) -> Result<Expr, String> {
        let expr = Expr(
            self.clone()
                .0
                .sort_by(robj_to!(VecPLExpr, by)?, robj_to!(Vec, bool, descending)?),
        );
        Ok(expr)
    }

    pub fn backward_fill(&self, limit: Nullable<f64>) -> Self {
        let lmt = null_to_opt(limit).map(|x| x as u32);
        self.clone().0.backward_fill(lmt).into()
    }

    pub fn forward_fill(&self, limit: Nullable<f64>) -> Self {
        let lmt = null_to_opt(limit).map(|x| x as u32);
        self.clone().0.forward_fill(lmt).into()
    }

    pub fn shift(&self, periods: f64) -> Self {
        self.clone().0.shift(periods as i64).into()
    }

    pub fn shift_and_fill(&self, periods: f64, fill_value: &Expr) -> Self {
        self.0
            .clone()
            .shift_and_fill(periods as i64, fill_value.0.clone())
            .into()
    }

    pub fn fill_null(&self, expr: &Expr) -> Self {
        self.0.clone().fill_null(expr.0.clone()).into()
    }

    pub fn fill_null_with_strategy(&self, strategy: &str, limit: Nullable<f64>) -> List {
        let res = || -> Result<Expr, String> {
            let limit = null_to_opt(limit).map(try_f64_into_usize).transpose()?;
            let limit: pl::FillNullLimit = limit.map(|x| x as u32);

            let strat = parse_fill_null_strategy(strategy, limit)
                .map_err(|err| format!("this happe4nd {:?}", err))?;
            let expr: pl::Expr = self
                .0
                .clone()
                .apply(
                    move |s| s.fill_null(strat).map(Some),
                    GetOutput::same_type(),
                )
                .with_fmt("fill_null_with_strategy");

            Ok(Expr(expr))
        }();
        r_result_list(res)
    }

    pub fn fill_nan(&self, expr: &Expr) -> Self {
        self.0.clone().fill_nan(expr.0.clone()).into()
    }

    pub fn reverse(&self) -> Self {
        self.0.clone().reverse().into()
    }

    pub fn std(&self, ddof: Robj) -> Result<Self, String> {
        Ok(self.clone().0.std(robj_to!(u8, ddof)?).into())
    }

    pub fn var(&self, ddof: Robj) -> Result<Self, String> {
        Ok(self.clone().0.var(robj_to!(u8, ddof)?).into())
    }

    pub fn max(&self) -> Self {
        self.0.clone().max().into()
    }

    pub fn min(&self) -> Self {
        self.0.clone().min().into()
    }

    pub fn nan_min(&self) -> Self {
        self.clone().0.nan_min().into()
    }

    pub fn nan_max(&self) -> Self {
        self.clone().0.nan_max().into()
    }

    pub fn mean(&self) -> Self {
        self.0.clone().mean().into()
    }

    pub fn median(&self) -> Self {
        self.0.clone().median().into()
    }

    pub fn sum(&self) -> Self {
        self.0.clone().sum().into()
    }

    pub fn product(&self) -> Self {
        self.clone().0.product().into()
    }

    pub fn n_unique(&self) -> Self {
        self.0.clone().n_unique().into()
    }

    pub fn null_count(&self) -> Self {
        self.0.clone().null_count().into()
    }

    pub fn arg_unique(&self) -> Self {
        self.clone().0.arg_unique().into()
    }

    pub fn is_duplicated(&self) -> Self {
        self.clone().0.is_duplicated().into()
    }

    pub fn quantile(&self, quantile: &Expr, interpolation: &str) -> List {
        let res = new_quantile_interpolation_option(interpolation)
            .map(|intpl| Expr(self.clone().0.quantile(quantile.0.clone(), intpl)));
        r_result_list(res)
    }

    pub fn filter(&self, predicate: &Expr) -> Expr {
        self.clone().0.filter(predicate.0.clone()).into()
    }

    pub fn explode(&self) -> Expr {
        self.clone().0.explode().into()
    }
    pub fn flatten(&self) -> Expr {
        //same as explode
        self.clone().0.explode().into()
    }

    pub fn take_every(&self, n: f64) -> List {
        use pl::*; //dunno what set of traits needed just take all

        let result = try_f64_into_usize_no_zero(n)
            .map_err(|err| format!("Invalid n argument in take_every: {}", err))
            .map(|n| {
                Expr(
                    self.clone()
                        .0
                        .map(
                            move |s: Series| Ok(Some(s.take_every(n))),
                            GetOutput::same_type(),
                        )
                        .with_fmt("take_every"),
                )
            });

        r_result_list(result)
    }

    pub fn hash(
        &self,
        seed: Robj,
        seed_1: Robj,
        seed_2: Robj,
        seed_3: Robj,
    ) -> Result<Expr, String> {
        Ok(Expr(self.0.clone().hash(
            robj_to!(u64, seed)?,
            robj_to!(u64, seed_1)?,
            robj_to!(u64, seed_2)?,
            robj_to!(u64, seed_3)?,
        )))
    }

    pub fn reinterpret(&self, signed: bool) -> Expr {
        use crate::utils::reinterpret;
        let function = move |s: pl::Series| reinterpret(&s, signed).map(Some);
        let dt = if signed {
            pl::DataType::Int64
        } else {
            pl::DataType::UInt64
        };
        self.clone()
            .0
            .map(function, GetOutput::from_type(dt))
            .into()
    }

    pub fn interpolate(&self, method: &str) -> List {
        use crate::rdatatype::new_interpolation_method;
        let im_result = new_interpolation_method(method)
            .map(|im| Expr(self.0.clone().interpolate(im)))
            .map_err(|err| format!("in interpolate(): {}", err));
        r_result_list(im_result)
    }

    pub fn rolling_min(
        &self,
        window_size: &str,
        weights_robj: Nullable<Vec<f64>>,
        min_periods_float: f64,
        center: bool,
        by_null: Nullable<String>,
        closed_null: Nullable<String>,
    ) -> List {
        let expr = make_rolling_options(
            window_size,
            weights_robj,
            min_periods_float,
            center,
            by_null,
            closed_null,
        )
        .map_err(|err| format!("rolling_min: {}", err))
        .map(|opts| Expr(self.0.clone().rolling_min(opts)));
        r_result_list(expr)
    }

    pub fn rolling_max(
        &self,
        window_size: &str,
        weights_robj: Nullable<Vec<f64>>,
        min_periods_float: f64,
        center: bool,
        by_null: Nullable<String>,
        closed_null: Nullable<String>,
    ) -> List {
        let expr = make_rolling_options(
            window_size,
            weights_robj,
            min_periods_float,
            center,
            by_null,
            closed_null,
        )
        .map_err(|err| format!("rolling_max: {}", err))
        .map(|opts| Expr(self.0.clone().rolling_max(opts)));
        r_result_list(expr)
    }

    pub fn rolling_mean(
        &self,
        window_size: &str,
        weights_robj: Nullable<Vec<f64>>,
        min_periods_float: f64,
        center: bool,
        by_null: Nullable<String>,
        closed_null: Nullable<String>,
    ) -> List {
        let expr = make_rolling_options(
            window_size,
            weights_robj,
            min_periods_float,
            center,
            by_null,
            closed_null,
        )
        .map_err(|err| format!("rolling_mean: {}", err))
        .map(|opts| Expr(self.0.clone().rolling_mean(opts)));
        r_result_list(expr)
    }

    pub fn rolling_sum(
        &self,
        window_size: &str,
        weights_robj: Nullable<Vec<f64>>,
        min_periods_float: f64,
        center: bool,
        by_null: Nullable<String>,
        closed_null: Nullable<String>,
    ) -> List {
        let expr = make_rolling_options(
            window_size,
            weights_robj,
            min_periods_float,
            center,
            by_null,
            closed_null,
        )
        .map_err(|err| format!("rolling_sum: {}", err))
        .map(|opts| Expr(self.0.clone().rolling_sum(opts)));
        r_result_list(expr)
    }

    pub fn rolling_std(
        &self,
        window_size: &str,
        weights_robj: Nullable<Vec<f64>>,
        min_periods_float: f64,
        center: bool,
        by_null: Nullable<String>,
        closed_null: Nullable<String>,
    ) -> List {
        let expr = make_rolling_options(
            window_size,
            weights_robj,
            min_periods_float,
            center,
            by_null,
            closed_null,
        )
        .map_err(|err| format!("rolling_std: {}", err))
        .map(|opts| Expr(self.0.clone().rolling_std(opts)));
        r_result_list(expr)
    }

    pub fn rolling_var(
        &self,
        window_size: &str,
        weights_robj: Nullable<Vec<f64>>,
        min_periods_float: f64,
        center: bool,
        by_null: Nullable<String>,
        closed_null: Nullable<String>,
    ) -> List {
        let expr = make_rolling_options(
            window_size,
            weights_robj,
            min_periods_float,
            center,
            by_null,
            closed_null,
        )
        .map_err(|err| format!("rolling_var: {}", err))
        .map(|opts| Expr(self.0.clone().rolling_var(opts)));
        r_result_list(expr)
    }

    pub fn rolling_median(
        &self,
        window_size: &str,
        weights_robj: Nullable<Vec<f64>>,
        min_periods_float: f64,
        center: bool,
        by_null: Nullable<String>,
        closed_null: Nullable<String>,
    ) -> List {
        let expr = make_rolling_options(
            window_size,
            weights_robj,
            min_periods_float,
            center,
            by_null,
            closed_null,
        )
        .map_err(|err| format!("rolling_median: {}", err))
        .map(|opts| Expr(self.0.clone().rolling_median(opts)));
        r_result_list(expr)
    }
    #[allow(clippy::too_many_arguments)]
    pub fn rolling_quantile(
        &self,
        quantile: f64,
        interpolation: &str,
        window_size: &str,
        weights_robj: Nullable<Vec<f64>>,
        min_periods_float: f64,
        center: bool,
        by_null: Nullable<String>,
        closed_null: Nullable<String>,
    ) -> List {
        let expr = make_rolling_options(
            window_size,
            weights_robj,
            min_periods_float,
            center,
            by_null,
            closed_null,
        )
        .and_then(|opts| {
            let interpolation = new_quantile_interpolation_option(interpolation)?;
            Ok(Expr(self.0.clone().rolling_quantile(
                quantile,
                interpolation,
                opts,
            )))
        })
        .map_err(|err| format!("rolling_quantile: {}", err));
        r_result_list(expr)
    }

    pub fn rolling_skew(&self, window_size_f: f64, bias: bool) -> List {
        use pl::*;
        let expr =
            try_f64_into_usize(window_size_f).map(|ws| {
                Expr(self.0.clone().rolling_apply_float(ws, move |ca| {
                    ca.clone().into_series().skew(bias).unwrap()
                }))
            });
        r_result_list(expr)
    }

    pub fn abs(&self) -> Self {
        self.0.clone().abs().into()
    }

    // TODO: support seed option
    fn rank(&self, method: &str, descending: bool) -> List {
        let expr_res = new_rank_method(method)
            .map(|rank_method| {
                let options = pl::RankOptions {
                    method: rank_method,
                    descending: descending,
                };
                Expr(self.0.clone().rank(options, Some(0u64)))
            })
            .map_err(|err| format!("rank: {}", err));

        r_result_list(expr_res)
    }

    fn diff(&self, n_float: f64, null_behavior: &str) -> List {
        let expr_res = || -> Result<Expr, String> {
            Ok(Expr(self.0.clone().diff(
                try_f64_into_i64(n_float)?,
                new_null_behavior(null_behavior)?,
            )))
        }()
        .map_err(|err| format!("diff: {}", err));
        r_result_list(expr_res)
    }

    fn pct_change(&self, n_float: f64) -> List {
        let expr_res = try_f64_into_i64(n_float)
            .map(|n| Expr(self.0.clone().pct_change(n)))
            .map_err(|err| format!("pct_change: {}", err));
        r_result_list(expr_res)
    }

    fn skew(&self, bias: bool) -> Self {
        self.0.clone().skew(bias).into()
    }
    fn kurtosis(&self, fisher: bool, bias: bool) -> Self {
        self.0.clone().kurtosis(fisher, bias).into()
    }

    //Note clip is implemented a bit different that py-polars
    //instead of PyValue -> AnyValue , it goes Robj -> Literal Expression -> AnyValue
    pub fn clip(&self, min: &Expr, max: &Expr) -> List {
        use crate::rdatatype::literal_to_any_value;
        let expr_res = || -> Result<Expr, String> {
            match (min.clone().0, max.clone().0) {
                (pl::Expr::Literal(mi), pl::Expr::Literal(ma)) => {
                    let av_min = literal_to_any_value(mi)?;
                    let av_max = literal_to_any_value(ma)?;
                    Ok(Expr(self.0.clone().clip(av_min, av_max)))
                }
                (mi, pl::Expr::Literal(_)) => Err(format!("min [{:?}] was not a literal:", mi)),
                (pl::Expr::Literal(_), ma) => Err(format!("max [{:?}] was not a literal:", ma)),
                (mi, ma) => Err(format!(
                    "neither min [{:?}] or max[{:?}] were literals:",
                    mi, ma
                )),
            }
        }();
        r_result_list(expr_res)
    }

    pub fn clip_min(&self, min: &Expr) -> List {
        use crate::rdatatype::literal_to_any_value;
        let expr_res = || -> Result<Expr, String> {
            match min.clone().0 {
                pl::Expr::Literal(mi) => {
                    let av_min = literal_to_any_value(mi)?;
                    Ok(Expr(self.0.clone().clip_min(av_min)))
                }
                mi => Err(format!("min [{:?}] was not a literal:", mi)),
            }
        }();
        r_result_list(expr_res)
    }

    pub fn clip_max(&self, max: &Expr) -> List {
        use crate::rdatatype::literal_to_any_value;
        let expr_res = || -> Result<Expr, String> {
            match max.clone().0 {
                pl::Expr::Literal(ma) => {
                    let av_max = literal_to_any_value(ma)?;
                    Ok(Expr(self.0.clone().clip_max(av_max)))
                }
                ma => Err(format!("max [{:?}] was not a literal:", ma)),
            }
        }();
        r_result_list(expr_res)
    }

    pub fn lower_bound(&self) -> Self {
        self.0.clone().lower_bound().into()
    }

    pub fn upper_bound(&self) -> Self {
        self.0.clone().upper_bound().into()
    }

    pub fn sign(&self) -> Self {
        self.clone().0.sign().into()
    }

    pub fn sin(&self) -> Self {
        self.clone().0.sin().into()
    }

    pub fn cos(&self) -> Self {
        self.clone().0.cos().into()
    }

    pub fn tan(&self) -> Self {
        self.clone().0.tan().into()
    }

    pub fn arcsin(&self) -> Self {
        self.clone().0.arcsin().into()
    }

    pub fn arccos(&self) -> Self {
        self.clone().0.arccos().into()
    }

    pub fn arctan(&self) -> Self {
        self.clone().0.arctan().into()
    }

    pub fn sinh(&self) -> Self {
        self.clone().0.sinh().into()
    }

    pub fn cosh(&self) -> Self {
        self.clone().0.cosh().into()
    }

    pub fn tanh(&self) -> Self {
        self.clone().0.tanh().into()
    }

    pub fn arcsinh(&self) -> Self {
        self.clone().0.arcsinh().into()
    }

    pub fn arccosh(&self) -> Self {
        self.clone().0.arccosh().into()
    }

    pub fn arctanh(&self) -> Self {
        self.clone().0.arctanh().into()
    }

    pub fn reshape(&self, dims: Vec<f64>) -> List {
        let dims_result: Result<Vec<i64>, String> = dims
            .iter()
            .map(|x| try_f64_into_i64(*x).map_err(String::from))
            .collect();
        let expr_result = dims_result
            .map(|dims| Expr(self.0.clone().reshape(&dims[..])))
            .map_err(|err| format!("reshape: {}", err));
        r_result_list(expr_result)
    }

    pub fn shuffle(&self, seed: f64) -> List {
        let seed_res =
            try_f64_into_usize(seed).map(|s| Expr(self.0.clone().shuffle(Some(s as u64))));
        r_result_list(seed_res)
    }

    pub fn sample_n(&self, n: f64, with_replacement: bool, shuffle: bool, seed: f64) -> List {
        let expr_result = || -> Result<Expr, String> {
            let seed = try_f64_into_usize(seed)?;
            let n = try_f64_into_usize(n)?;
            Ok(self
                .0
                .clone()
                .sample_n(n, with_replacement, shuffle, Some(seed as u64))
                .into())
        }();
        r_result_list(expr_result)
    }

    pub fn sample_frac(&self, frac: f64, with_replacement: bool, shuffle: bool, seed: f64) -> List {
        let expr_result = || -> Result<Expr, String> {
            let seed = try_f64_into_usize(seed)?;
            Ok(self
                .0
                .clone()
                .sample_frac(frac, with_replacement, shuffle, Some(seed as u64))
                .into())
        }();
        r_result_list(expr_result)
    }

    pub fn ewm_mean(&self, alpha: f64, adjust: bool, min_periods: f64, ignore_nulls: bool) -> List {
        let expr_result = || -> Result<Expr, String> {
            let min_periods = try_f64_into_usize(min_periods)?;
            let options = pl::EWMOptions {
                alpha,
                adjust,
                bias: false,
                min_periods,
                ignore_nulls,
            };
            Ok(self.0.clone().ewm_mean(options).into())
        }();
        r_result_list(expr_result)
    }

    pub fn ewm_std(
        &self,
        alpha: f64,
        adjust: bool,
        bias: bool,
        min_periods: f64,
        ignore_nulls: bool,
    ) -> List {
        let expr_result = || -> Result<Expr, String> {
            let min_periods = try_f64_into_usize(min_periods)?;
            let options = pl::EWMOptions {
                alpha,
                adjust,
                bias,
                min_periods,
                ignore_nulls,
            };
            Ok(self.0.clone().ewm_std(options).into())
        }();
        r_result_list(expr_result)
    }

    pub fn ewm_var(
        &self,
        alpha: f64,
        adjust: bool,
        bias: bool,
        min_periods: f64,
        ignore_nulls: bool,
    ) -> List {
        let expr_result = || -> Result<Expr, String> {
            let min_periods = try_f64_into_usize(min_periods)?;
            let options = pl::EWMOptions {
                alpha,
                adjust,
                bias,
                min_periods,
                ignore_nulls,
            };
            Ok(self.0.clone().ewm_var(options).into())
        }();
        r_result_list(expr_result)
    }

    pub fn extend_constant(&self, value: &Expr, n: f64) -> List {
        let expr_res = || -> Result<Expr, String> {
            let av = match value.clone().0 {
                pl::Expr::Literal(ma) => literal_to_any_value(ma),
                ma => Err(format!("value [{:?}] was not a literal:", ma)),
            }?;
            let n = try_f64_into_usize(n)?;

            Ok(Expr(
                self.0
                    .clone()
                    .apply(
                        move |s| {
                            //swap owned inline string to str as only supported and if swapped here life time is long enough
                            let av = match &av {
                                pl::AnyValue::Utf8Owned(x) => pl::AnyValue::Utf8(x.as_str()),
                                x => x.clone(),
                            };
                            s.extend_constant(av, n).map(Some)
                        },
                        GetOutput::same_type(),
                    )
                    .with_fmt("extend"),
            ))
        }();
        r_result_list(expr_res)
    }

    pub fn rep(&self, n: f64, rechunk: bool) -> List {
        match try_f64_into_usize(n) {
            Err(err) => r_error_list(format!("rep: arg n invalid, {}", err)),
            Ok(n) => r_ok_list(Expr(
                self.0
                    .clone()
                    .apply(
                        move |s| {
                            if s.len() == 1 {
                                Ok(Some(s.new_from_index(0, n)))
                            } else {
                                Series(s).rep_impl(n, rechunk).map(|s| Some(s.0))
                            }
                        },
                        GetOutput::same_type(),
                    )
                    .with_fmt("rep"),
            )),
        }
    }

    pub fn value_counts(&self, multithreaded: bool, sorted: bool) -> Self {
        self.0.clone().value_counts(multithreaded, sorted).into()
    }

    pub fn unique_counts(&self) -> Self {
        self.0.clone().unique_counts().into()
    }

    pub fn entropy(&self, base: f64, normalize: bool) -> Self {
        self.0.clone().entropy(base, normalize).into()
    }

    fn cumulative_eval(&self, expr: &Expr, min_periods: f64, parallel: bool) -> List {
        use pl::*;
        r_result_list(try_f64_into_usize(min_periods).map(|min_p| {
            Expr(
                self.0
                    .clone()
                    .cumulative_eval(expr.0.clone(), min_p, parallel),
            )
        }))
    }

    pub fn implode(&self) -> Self {
        self.clone().0.implode().into()
    }

    pub fn shrink_dtype(&self) -> Self {
        self.0.clone().shrink_dtype().into()
    }

    //arr/list methods

    fn arr_lengths(&self) -> Self {
        self.0.clone().list().lengths().into()
    }

    pub fn arr_contains(&self, other: &Expr) -> Expr {
        self.0.clone().list().contains(other.0.clone()).into()
    }

    fn lst_max(&self) -> Self {
        self.0.clone().list().max().into()
    }

    fn lst_min(&self) -> Self {
        self.0.clone().list().min().into()
    }

    fn lst_sum(&self) -> Self {
        self.0.clone().list().sum().with_fmt("arr.sum").into()
    }

    fn lst_mean(&self) -> Self {
        self.0.clone().list().mean().with_fmt("arr.mean").into()
    }

    fn lst_sort(&self, descending: bool) -> Self {
        self.0
            .clone()
            .list()
            .sort(SortOptions {
                descending: descending,
                ..Default::default()
            })
            .with_fmt("arr.sort")
            .into()
    }

    fn lst_reverse(&self) -> Self {
        self.0
            .clone()
            .list()
            .reverse()
            .with_fmt("arr.reverse")
            .into()
    }

    fn lst_unique(&self) -> Self {
        self.0.clone().list().unique().with_fmt("arr.unique").into()
    }

    fn lst_take(&self, index: &Expr, null_on_oob: bool) -> Self {
        self.0
            .clone()
            .list()
            .take(index.0.clone(), null_on_oob)
            .into()
    }

    fn lst_get(&self, index: &Expr) -> Self {
        self.0.clone().list().get(index.clone().0).into()
    }

    fn lst_join(&self, separator: &str) -> Self {
        self.0.clone().list().join(separator).into()
    }

    fn lst_arg_min(&self) -> Self {
        self.0.clone().list().arg_min().into()
    }

    fn lst_arg_max(&self) -> Self {
        self.0.clone().list().arg_max().into()
    }

    fn lst_diff(&self, n: f64, null_behavior: &str) -> List {
        let expr_res = || -> Result<Expr, String> {
            Ok(Expr(self.0.clone().list().diff(
                try_f64_into_i64(n)?,
                new_null_behavior(null_behavior)?,
            )))
        }()
        .map_err(|err| format!("arr.diff: {}", err));
        r_result_list(expr_res)
    }

    fn lst_shift(&self, periods: f64) -> List {
        let expr_res = || -> Result<Expr, String> {
            Ok(Expr(
                self.0.clone().list().shift(try_f64_into_i64(periods)?),
            ))
        }()
        .map_err(|err| format!("arr.shift: {}", err));
        r_result_list(expr_res)
    }

    fn lst_slice(&self, offset: &Expr, length: Nullable<&Expr>) -> Self {
        let length = match null_to_opt(length) {
            Some(i) => i.0.clone(),
            None => dsl::lit(i64::MAX),
        };
        self.0.clone().list().slice(offset.0.clone(), length).into()
    }

    fn lst_eval(&self, expr: &Expr, parallel: bool) -> Self {
        use pl::*;
        self.0.clone().list().eval(expr.0.clone(), parallel).into()
    }

    fn lst_to_struct(&self, width_strat: &str, name_gen: Nullable<Robj>, upper_bound: f64) -> List {
        use crate::rdatatype::new_width_strategy;
        use crate::utils::extendr_concurrent::ParRObj;
        use pl::NamedFrom;
        use smartstring::{LazyCompact, SmartString};
        use std::sync::Arc;
        // TODO improve extendr_concurrent to support other closures thatn |Series|->Series
        // here a usize is wrapped in Series
        let name_gen: std::option::Option<
            Arc<(dyn Fn(usize) -> SmartString<LazyCompact> + Send + Sync + 'static)>,
        > = if let Some(robj) = null_to_opt(name_gen) {
            let probj: ParRObj = robj.into();
            let x: std::option::Option<
                Arc<(dyn Fn(usize) -> SmartString<LazyCompact> + Send + Sync + 'static)>,
            > = Some(pl::Arc::new(move |idx: usize| {
                let thread_com = ThreadCom::from_global(&CONFIG);
                let s = pl::Series::new("", &[idx as u64]);
                thread_com.send((probj.clone(), s));
                let s = thread_com.recv();
                let s: SmartString<LazyCompact> = s.0.name().to_string().into();
                s
            }));
            x
        } else {
            None
        };

        //resolve usize from f64 and stategy from str
        let res = || -> Result<Expr, String> {
            let ub = try_f64_into_usize(upper_bound)?;
            let strat = new_width_strategy(width_strat)?;
            Ok(Expr(self.0.clone().list().to_struct(strat, name_gen, ub)))
        }();

        let res = res.map_err(|err| format!("in to_struct: {}", err));

        r_result_list(res)
    }

    pub fn str_parse_date(
        &self,
        format: Nullable<String>,
        strict: bool,
        exact: bool,
        cache: bool,
    ) -> Self {
        self.0
            .clone()
            .str()
            .strptime(
                pl::DataType::Date,
                pl::StrptimeOptions {
                    format: null_to_opt(format),
                    strict,
                    exact,
                    cache,
                },
            )
            .into()
    }

    #[allow(clippy::too_many_arguments)]
    pub fn str_parse_datetime(
        &self,
        format: Nullable<String>,
        strict: bool,
        exact: bool,
        cache: bool,
        tu: Nullable<Robj>,
    ) -> List {
        let res = || -> Result<Expr, String> {
            let tu = null_to_opt(tu).map(robj_to_timeunit).transpose()?;
            let format = null_to_opt(format);
            let result_tu = match (&format, tu) {
                (_, Some(tu)) => tu,
                (Some(format), None) => {
                    if format.contains("%.9f")
                        || format.contains("%9f")
                        || format.contains("%f")
                        || format.contains("%.f")
                    {
                        pl::TimeUnit::Nanoseconds
                    } else if format.contains("%.3f") || format.contains("%3f") {
                        pl::TimeUnit::Milliseconds
                    } else {
                        pl::TimeUnit::Microseconds
                    }
                }
                (None, None) => pl::TimeUnit::Microseconds,
            };
            Ok(self
                .0
                .clone()
                .str()
                .strptime(
                    pl::DataType::Datetime(result_tu, None),
                    pl::StrptimeOptions {
                        format,
                        strict,
                        exact,
                        cache,
                    },
                )
                .into())
        }();
        r_result_list(res)
    }

    pub fn str_parse_time(
        &self,
        format: Nullable<String>,
        strict: bool,
        exact: bool,
        cache: bool,
    ) -> Self {
        self.0
            .clone()
            .str()
            .strptime(
                pl::DataType::Time,
                pl::StrptimeOptions {
                    format: null_to_opt(format),
                    strict,
                    exact,
                    cache,
                },
            )
            .into()
    }

    //end list/arr methods

    pub fn dt_truncate(&self, every: &str, offset: &str) -> Self {
        self.0.clone().dt().truncate(every, offset).into()
    }

    pub fn dt_round(&self, every: &str, offset: &str) -> Self {
        self.0.clone().dt().round(every, offset).into()
    }

    pub fn dt_combine(&self, time: &Expr, tu: Robj) -> List {
        let res =
            robj_to_timeunit(tu).map(|tu| Expr(self.0.clone().dt().combine(time.0.clone(), tu)));

        r_result_list(res)
    }

    pub fn dt_strftime(&self, fmt: &str) -> Self {
        //named strftime in py-polars
        self.0.clone().dt().strftime(fmt).into()
    }
    pub fn dt_year(&self) -> Self {
        //named year in py-polars
        self.clone().0.dt().year().into()
    }
    pub fn dt_iso_year(&self) -> Self {
        //named iso_year in py-polars
        self.clone().0.dt().iso_year().into()
    }

    pub fn dt_quarter(&self) -> Self {
        self.clone().0.dt().quarter().into()
    }
    pub fn dt_month(&self) -> Self {
        self.clone().0.dt().month().into()
    }
    pub fn dt_week(&self) -> Self {
        self.clone().0.dt().week().into()
    }
    pub fn dt_weekday(&self) -> Self {
        self.clone().0.dt().weekday().into()
    }
    pub fn dt_day(&self) -> Self {
        self.clone().0.dt().day().into()
    }
    pub fn dt_ordinal_day(&self) -> Self {
        self.clone().0.dt().ordinal_day().into()
    }
    pub fn dt_hour(&self) -> Self {
        self.clone().0.dt().hour().into()
    }
    pub fn dt_minute(&self) -> Self {
        self.clone().0.dt().minute().into()
    }
    pub fn dt_second(&self) -> Self {
        self.clone().0.dt().second().into()
    }
    pub fn dt_millisecond(&self) -> Self {
        self.clone().0.dt().millisecond().into()
    }
    pub fn dt_microsecond(&self) -> Self {
        self.clone().0.dt().microsecond().into()
    }
    pub fn dt_nanosecond(&self) -> Self {
        self.clone().0.dt().nanosecond().into()
    }

    pub fn timestamp(&self, tu: Robj) -> List {
        let res = robj_to_timeunit(tu)
            .map(|tu| Expr(self.0.clone().dt().timestamp(tu)))
            .map_err(|err| format!("valid tu needed for timestamp: {}", err));
        r_result_list(res)
    }

    pub fn dt_epoch_seconds(&self) -> Self {
        self.clone()
            .0
            .map(
                |s| {
                    s.timestamp(pl::TimeUnit::Milliseconds)
                        .map(|ca| Some((ca / 1000).into_series()))
                },
                pl::GetOutput::from_type(pl::DataType::Int64),
            )
            .into()
    }

    pub fn dt_with_time_unit(&self, tu: Robj) -> List {
        let expr_result =
            robj_to_timeunit(tu).map(|tu| Expr(self.0.clone().dt().with_time_unit(tu)));
        r_result_list(expr_result)
    }

    pub fn dt_cast_time_unit(&self, tu: Robj) -> List {
        let expr_result =
            robj_to_timeunit(tu).map(|tu| Expr(self.0.clone().dt().cast_time_unit(tu)));

        r_result_list(expr_result)
    }

    pub fn dt_convert_time_zone(&self, tz: String) -> Self {
        self.0.clone().dt().convert_time_zone(tz).into()
    }

    pub fn dt_replace_time_zone(&self, tz: Nullable<String>, use_earliest: Nullable<bool>) -> Self {
        self.0
            .clone()
            .dt()
            .replace_time_zone(tz.into_option(), use_earliest.into_option())
            .into()
    }

    #[allow(deprecated)]
    pub fn dt_tz_localize(&self, tz: String) -> Self {
        self.0.clone().dt().tz_localize(tz).into()
    }

    pub fn duration_days(&self) -> Self {
        self.0
            .clone()
            .map(
                |s| Ok(Some(s.duration()?.days().into_series())),
                GetOutput::from_type(pl::DataType::Int64),
            )
            .into()
    }
    pub fn duration_hours(&self) -> Self {
        self.0
            .clone()
            .map(
                |s| Ok(Some(s.duration()?.hours().into_series())),
                GetOutput::from_type(pl::DataType::Int64),
            )
            .into()
    }
    pub fn duration_minutes(&self) -> Self {
        self.0
            .clone()
            .map(
                |s| Ok(Some(s.duration()?.minutes().into_series())),
                GetOutput::from_type(pl::DataType::Int64),
            )
            .into()
    }
    pub fn duration_seconds(&self) -> Self {
        self.0
            .clone()
            .map(
                |s| Ok(Some(s.duration()?.seconds().into_series())),
                GetOutput::from_type(pl::DataType::Int64),
            )
            .into()
    }
    pub fn duration_nanoseconds(&self) -> Self {
        self.0
            .clone()
            .map(
                |s| Ok(Some(s.duration()?.nanoseconds().into_series())),
                GetOutput::from_type(pl::DataType::Int64),
            )
            .into()
    }
    pub fn duration_microseconds(&self) -> Self {
        self.0
            .clone()
            .map(
                |s| Ok(Some(s.duration()?.microseconds().into_series())),
                GetOutput::from_type(pl::DataType::Int64),
            )
            .into()
    }
    pub fn duration_milliseconds(&self) -> Self {
        self.0
            .clone()
            .map(
                |s| Ok(Some(s.duration()?.milliseconds().into_series())),
                GetOutput::from_type(pl::DataType::Int64),
            )
            .into()
    }

    pub fn dt_offset_by(&self, by: &str) -> Self {
        let by = pl::Duration::parse(by);
        self.clone().0.dt().offset_by(by).into()
    }

    pub fn pow(&self, exponent: Robj) -> RResult<Self> {
        Ok(self.0.clone().pow(robj_to!(PLExpr, exponent)?).into())
    }

    pub fn repeat_by(&self, by: &Expr) -> Self {
        self.clone().0.repeat_by(by.0.clone()).into()
    }

    pub fn log10(&self) -> Self {
        self.0.clone().log(10.0).into()
    }

    // TODO contribute to polars
    // log/exp only takes float, whereas pow takes Into<Expr>
    // log takes a base value, whereas exp only is natural log

    pub fn log(&self, base: f64) -> Self {
        self.0.clone().log(base).into()
    }

    pub fn exp(&self) -> Self {
        self.0.clone().exp().into()
    }

    pub fn exclude(&self, columns: Vec<String>) -> Self {
        self.0.clone().exclude(columns).into()
    }

    pub fn exclude_dtype(&self, columns: &DataTypeVector) -> Self {
        self.0.clone().exclude_dtype(columns.dtv_to_vec()).into()
    }

    pub fn keep_name(&self) -> Self {
        self.0.clone().keep_name().into()
    }

    pub fn alias(&self, s: &str) -> Self {
        self.0.clone().alias(s).into()
    }

    pub fn is_null(&self) -> Self {
        self.0.clone().is_null().into()
    }

    pub fn is_not_null(&self) -> Self {
        self.0.clone().is_not_null().into()
    }

    pub fn is_finite(&self) -> Self {
        self.0.clone().is_finite().into()
    }

    pub fn is_infinite(&self) -> Self {
        self.0.clone().is_infinite().into()
    }

    pub fn is_nan(&self) -> Self {
        self.0.clone().is_nan().into()
    }

    pub fn is_not_nan(&self) -> Self {
        self.0.clone().is_not_nan().into()
    }

    pub fn drop_nulls(&self) -> Self {
        self.0.clone().drop_nulls().into()
    }

    pub fn drop_nans(&self) -> Self {
        self.0.clone().drop_nans().into()
    }

    pub fn cumsum(&self, reverse: bool) -> Self {
        self.0.clone().cumsum(reverse).into()
    }

    pub fn cumprod(&self, reverse: bool) -> Self {
        self.0.clone().cumprod(reverse).into()
    }

    pub fn cummin(&self, reverse: bool) -> Self {
        self.0.clone().cummin(reverse).into()
    }

    pub fn cummax(&self, reverse: bool) -> Self {
        self.0.clone().cummax(reverse).into()
    }

    pub fn cumcount(&self, reverse: bool) -> Self {
        self.0.clone().cumcount(reverse).into()
    }

    pub fn floor(&self) -> Self {
        self.0.clone().floor().into()
    }

    pub fn ceil(&self) -> Self {
        self.0.clone().ceil().into()
    }

    pub fn round(&self, decimals: f64) -> List {
        let res = try_f64_into_u32(decimals)
            .map_err(|err| format!("in round: {}", err))
            .map(|n| Expr(self.0.clone().round(n)));
        r_result_list(res)
    }

    pub fn dot(&self, other: &Expr) -> Self {
        self.0.clone().dot(other.0.clone()).into()
    }

    pub fn mode(&self) -> Self {
        self.0.clone().mode().into()
    }

    pub fn first(&self) -> Self {
        self.0.clone().first().into()
    }

    pub fn last(&self) -> Self {
        self.0.clone().last().into()
    }

    pub fn head(&self, n: Robj) -> Result<Self, String> {
        Ok(self.0.clone().head(Some(robj_to!(usize, n)?)).into())
    }

    pub fn tail(&self, n: Robj) -> Result<Self, String> {
        Ok(self.0.clone().tail(Some(robj_to!(usize, n)?)).into())
    }

    //chaining methods

    pub fn unique(&self) -> Self {
        self.0.clone().unique().into()
    }

    pub fn unique_stable(&self) -> Self {
        self.0.clone().unique_stable().into()
    }

    pub fn agg_groups(&self) -> Self {
        self.0.clone().agg_groups().into()
    }

    pub fn all(&self) -> Self {
        self.0.clone().all().into()
    }
    pub fn any(&self) -> Self {
        self.0.clone().any().into()
    }

    pub fn count(&self) -> Self {
        self.0.clone().count().into()
    }

    pub fn len(&self) -> Self {
        self.0.clone().count().into()
    }

    pub fn slice(&self, offset: &Expr, length: Nullable<&Expr>) -> Self {
        let length = match null_to_opt(length) {
            Some(i) => i.0.clone(),
            None => dsl::lit(i64::MAX),
        };
        self.0.clone().slice(offset.0.clone(), length).into()
    }

    pub fn append(&self, other: &Expr, upcast: bool) -> Self {
        self.0.clone().append(other.0.clone(), upcast).into()
    }

    pub fn rechunk(&self) -> Self {
        self.0
            .clone()
            .map(|s| Ok(Some(s.rechunk())), GetOutput::same_type())
            .into()
    }

    //binary arithmetic expressions
    pub fn add(&self, other: Robj) -> RResult<Self> {
        Ok(self.0.clone().add(robj_to!(PLExpr, other)?).into())
    }

    //binary arithmetic expressions
    pub fn sub(&self, other: Robj) -> RResult<Self> {
        Ok(self.0.clone().sub(robj_to!(PLExpr, other)?).into())
    }

    pub fn mul(&self, other: Robj) -> RResult<Self> {
        Ok(self.0.clone().mul(robj_to!(PLExpr, other)?).into())
    }

    pub fn div(&self, other: Robj) -> RResult<Self> {
        Ok(self.0.clone().div(robj_to!(PLExpr, other)?).into())
    }

    //unary
    pub fn is_not(&self) -> Self {
        self.0.clone().not().into()
    }

    //expr      "funnies"
    pub fn over(&self, proto_exprs: &ProtoExprArray) -> Self {
        let ve = pra_to_vec(proto_exprs, "select");
        self.0.clone().over(ve).into()
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    pub fn map(
        &self,
        lambda: Robj,
        output_type: Nullable<&RPolarsDataType>,
        agg_list: bool,
    ) -> Self {
        use crate::utils::wrappers::null_to_opt;

        //find a way not to push lambda everytime to main thread handler
        //safety only accessed in main thread, can be temp owned by other threads
        let probj = ParRObj(lambda);
        //}

        let f = move |s: pl::Series| {
            //acquire channel to R via main thread handler
            let thread_com = ThreadCom::try_from_global(&CONFIG)
                .expect("polars was thread could not initiate ThreadCommunication to R");
            //this could happen if running in background mode, but inly panic is possible here

            //send request to run in R
            thread_com.send((probj.clone(), s));

            //recieve answer
            let s = thread_com.recv();

            //wrap as series
            Ok(Some(s))
        };

        let ot = null_to_opt(output_type).map(|rdt| rdt.0.clone());

        let output_map = pl::GetOutput::map_field(move |fld| match ot {
            Some(ref dt) => pl::Field::new(fld.name(), dt.clone()),
            None => fld.clone(),
        });

        if agg_list {
            self.clone().0.map_list(f, output_map)
        } else {
            self.clone().0.map(f, output_map)
        }
        .into()
    }

    pub fn map_in_background(
        &self,
        lambda: Robj,
        output_type: Nullable<&RPolarsDataType>,
        agg_list: bool,
    ) -> Self {
        let raw_func = crate::rbackground::serialize_robj(lambda).unwrap();

        let rbgfunc = move |s| {
            crate::RBGPOOL
                .rmap_series(raw_func.clone(), s)
                .map_err(rpolars_to_polars_err)?()
            .map_err(rpolars_to_polars_err)
            .map(Some)
        };

        let ot = null_to_opt(output_type).map(|rdt| rdt.0.clone());

        let output_map = pl::GetOutput::map_field(move |fld| match ot {
            Some(ref dt) => pl::Field::new(fld.name(), dt.clone()),
            None => fld.clone(),
        });

        if agg_list {
            self.clone().0.map_list(rbgfunc, output_map)
        } else {
            self.clone().0.map(rbgfunc, output_map)
        }
        .into()
    }

    pub fn apply_in_background(
        &self,
        lambda: Robj,
        output_type: Nullable<&RPolarsDataType>,
    ) -> Self {
        let raw_func = crate::rbackground::serialize_robj(lambda).unwrap();

        let rbgfunc = move |s| {
            crate::RBGPOOL
                .rmap_series(raw_func.clone(), s)
                .map_err(rpolars_to_polars_err)?()
            .map_err(rpolars_to_polars_err)
            .map(Some)
        };

        let ot = null_to_opt(output_type).map(|rdt| rdt.0.clone());

        let output_map = pl::GetOutput::map_field(move |fld| match ot {
            Some(ref dt) => pl::Field::new(fld.name(), dt.clone()),
            None => fld.clone(),
        });

        self.0.clone().apply(rbgfunc, output_map).into()
    }

    pub fn is_unique(&self) -> Self {
        self.0.clone().is_unique().into()
    }

    pub fn approx_unique(&self) -> Self {
        self.clone().0.approx_unique().into()
    }

    pub fn is_first(&self) -> Self {
        self.clone().0.is_first().into()
    }

    pub fn map_alias(&self, lambda: Robj) -> Self {
        //find a way not to push lambda everytime to main thread handler
        //safety only accessed in main thread, can be temp owned by other threads
        let probj = ParRObj(lambda);
        //}

        // let f = move |name: &str| -> String {
        //     //acquire channel to R via main thread handler
        //     let thread_com = ThreadCom::from_global(&CONFIG);

        //     //place name in Series because current version of ThreadCom only speaks series
        //     use polars::prelude::NamedFrom;
        //     let s = pl::Series::new(name, &[0]);

        //     //send request to run in R
        //     thread_com.send((probj.clone(), s));

        //     //recieve answer
        //     let s = thread_com.recv();

        //     s.0.name().to_string()

        //     //wrap as series
        // };

        let f = move |name: &str| -> pl::PolarsResult<String> {
            let robj = probj.clone().0;
            let rfun = robj
                .as_function()
                .expect("internal error: this is not an R function");

            let newname_robj = rfun.call(pairlist!(name)).map_err(|err| {
                let es = format!("in map_alias: user function raised this error: {:?}", err).into();
                pl_error::ComputeError(es)
            })?;

            newname_robj
                .as_str()
                .ok_or_else(|| {
                    let es = "in map_alias: R function return value was not a string"
                        .to_string()
                        .into();
                    pl_error::ComputeError(es)
                })
                .map(|str| str.to_string())
        };

        self.clone().0.map_alias(f).into()
    }

    fn suffix(&self, suffix: String) -> Self {
        self.0.clone().suffix(suffix.as_str()).into()
    }

    fn prefix(&self, prefix: String) -> Self {
        self.0.clone().prefix(prefix.as_str()).into()
    }

    //string methods
    pub fn str_lengths(&self) -> Self {
        use pl::*;
        let function = |s: pl::Series| {
            let ca = s.utf8()?;
            Ok(Some(ca.str_lengths().into_series()))
        };
        self.clone()
            .0
            .map(function, GetOutput::from_type(pl::DataType::UInt32))
            .with_fmt("str.lengths")
            .into()
    }

    pub fn str_n_chars(&self) -> Self {
        let function = |s: pl::Series| {
            let ca = s.utf8()?;
            Ok(Some(ca.str_n_chars().into_series()))
        };
        self.clone()
            .0
            .map(function, GetOutput::from_type(pl::DataType::UInt32))
            .with_fmt("str.n_chars")
            .into()
    }

    pub fn str_concat(&self, delimiter: &str) -> Self {
        self.0.clone().str().concat(delimiter).into()
    }

    pub fn str_to_uppercase(&self) -> Self {
        self.0.clone().str().to_uppercase().into()
    }

    pub fn str_to_lowercase(&self) -> Self {
        self.0.clone().str().to_lowercase().into()
    }

    pub fn str_strip(&self, matches: Nullable<String>) -> Self {
        self.0.clone().str().strip(null_to_opt(matches)).into()
    }

    pub fn str_rstrip(&self, matches: Nullable<String>) -> Self {
        self.0.clone().str().rstrip(null_to_opt(matches)).into()
    }

    pub fn str_lstrip(&self, matches: Nullable<String>) -> Self {
        self.0.clone().str().lstrip(null_to_opt(matches)).into()
    }

    pub fn str_zfill(&self, alignment: Robj) -> List {
        let res = robj_to!(usize, alignment, "in str$zfill()")
            .map(|alignment| Expr(self.clone().0.str().zfill(alignment)));
        r_result_list(res)
    }

    pub fn str_ljust(&self, width: Robj, fillchar: Robj) -> List {
        let res = || -> Result<Expr, String> {
            Ok(Expr(
                self.clone()
                    .0
                    .str()
                    .ljust(robj_to!(usize, width)?, robj_to!(char, fillchar)?),
            ))
        }()
        .map_err(|err| format!("in str$ljust: {:?}", err));
        r_result_list(res)
    }

    pub fn str_rjust(&self, width: Robj, fillchar: Robj) -> List {
        let res = || -> Result<Expr, String> {
            Ok(Expr(
                self.clone()
                    .0
                    .str()
                    .rjust(robj_to!(usize, width)?, robj_to!(char, fillchar)?),
            ))
        }()
        .map_err(|err| format!("in str$rjust: {:?}", err));
        r_result_list(res)
    }

    pub fn str_contains(&self, pat: &Expr, literal: Nullable<bool>, strict: bool) -> Self {
        Expr(match null_to_opt(literal) {
            Some(true) => self.0.clone().str().contains_literal(pat.0.clone()),
            _ => self.0.clone().str().contains(pat.0.clone(), strict),
        })
    }

    pub fn str_ends_with(&self, sub: &Expr) -> Self {
        self.0.clone().str().ends_with(sub.0.clone()).into()
    }

    pub fn str_starts_with(&self, sub: &Expr) -> Self {
        self.0.clone().str().starts_with(sub.0.clone()).into()
    }

    pub fn str_json_path_match(&self, pat: Robj) -> List {
        let res = || -> Result<Expr, String> {
            use pl::*;
            let pat: String = robj_to!(String, pat, "in str$json_path_match: {}")?;
            let function = move |s: Series| {
                let ca = s.utf8()?;
                match ca.json_path_match(&pat) {
                    Ok(ca) => Ok(Some(ca.into_series())),
                    Err(e) => Err(pl::PolarsError::ComputeError(format!("{e:?}").into())),
                }
            };
            Ok(Expr(
                self.0
                    .clone()
                    .map(function, GetOutput::from_type(pl::DataType::Utf8))
                    .with_fmt("str.json_path_match"),
            ))
        }();
        r_result_list(res)
    }

    pub fn str_json_extract(&self, dtype: Nullable<&RPolarsDataType>) -> Self {
        let dtype = null_to_opt(dtype).map(|dt| dt.0.clone());
        use pl::*;
        let output_type = match dtype.clone() {
            Some(dtype) => GetOutput::from_type(dtype),
            None => GetOutput::from_type(DataType::Unknown),
        };

        let function = move |s: Series| {
            let ca = s.utf8()?;
            match ca.json_extract(dtype.clone()) {
                Ok(ca) => Ok(Some(ca.into_series())),
                Err(e) => Err(PolarsError::ComputeError(format!("{e:?}").into())),
            }
        };

        self.0
            .clone()
            .map(function, output_type)
            .with_fmt("str.json_extract")
            .into()
    }

    pub fn str_hex_encode(&self) -> Self {
        use pl::*;
        self.clone()
            .0
            .map(
                move |s| s.utf8().map(|s| Some(s.hex_encode().into_series())),
                GetOutput::same_type(),
            )
            .with_fmt("str.hex_encode")
            .into()
    }

    pub fn str_hex_decode(&self, strict: bool) -> Self {
        use pl::*;
        self.clone()
            .0
            .map(
                move |s| s.utf8()?.hex_decode(strict).map(|s| Some(s.into_series())),
                GetOutput::same_type(),
            )
            .with_fmt("str.hex_decode")
            .into()
    }
    pub fn str_base64_encode(&self) -> Self {
        use pl::*;
        self.clone()
            .0
            .map(
                move |s| s.utf8().map(|s| Some(s.base64_encode().into_series())),
                GetOutput::same_type(),
            )
            .with_fmt("str.base64_encode")
            .into()
    }

    pub fn str_base64_decode(&self, strict: bool) -> Self {
        use pl::*;
        self.clone()
            .0
            .map(
                move |s| {
                    s.utf8()?
                        .base64_decode(strict)
                        .map(|s| Some(s.into_series()))
                },
                GetOutput::same_type(),
            )
            .with_fmt("str.base64_decode")
            .into()
    }

    pub fn str_extract(&self, pattern: Robj, group_index: Robj) -> List {
        let res = || -> Result<Expr, String> {
            let pat = robj_to!(String, pattern)?;
            let gi = robj_to!(usize, group_index)?;
            Ok(self.0.clone().str().extract(pat.as_str(), gi).into())
        }()
        .map_err(|err| format!("in str$extract: {}", err));
        r_result_list(res)
    }

    pub fn str_extract_all(&self, pattern: &Expr) -> Self {
        self.0.clone().str().extract_all(pattern.0.clone()).into()
    }

    pub fn str_count_match(&self, pattern: Robj) -> List {
        r_result_list(
            robj_to!(String, pattern, "in str$count_match:")
                .map(|s| Expr(self.0.clone().str().count_match(s.as_str()))),
        )
    }

    //NOTE SHOW CASE all R side argument handling
    pub fn str_split(&self, by: Robj, inclusive: Robj) -> Result<Expr, String> {
        let by = robj_to!(str, by)?;
        let inclusive = robj_to!(bool, inclusive)?;
        if inclusive {
            Ok(self.0.clone().str().split_inclusive(by).into())
        } else {
            Ok(self.0.clone().str().split(by).into())
        }
    }

    //NOTE SHOW CASE all rust side argument handling, n is usize and had to be
    //handled on rust side anyways
    pub fn str_split_exact(&self, by: Robj, n: Robj, inclusive: Robj) -> Result<Expr, String> {
        let by = robj_to!(str, by)?;
        let n = robj_to!(usize, n)?;
        let inclusive = robj_to!(bool, inclusive)?;
        Ok(if inclusive {
            self.0.clone().str().split_exact_inclusive(by, n)
        } else {
            self.0.clone().str().split_exact(by, n)
        }
        .into())
    }

    pub fn str_splitn(&self, by: Robj, n: Robj) -> Result<Expr, String> {
        Ok(self
            .0
            .clone()
            .str()
            .splitn(robj_to!(str, by)?, robj_to!(usize, n)?)
            .into())
    }

    pub fn str_replace(&self, pattern: Robj, value: Robj, literal: Robj) -> Result<Expr, String> {
        Ok(self
            .0
            .clone()
            .str()
            .replace(
                robj_to!(Expr, pattern)?.0,
                robj_to!(Expr, value)?.0,
                robj_to!(bool, literal)?,
            )
            .into())
    }

    pub fn str_replace_all(
        &self,
        pattern: Robj,
        value: Robj,
        literal: Robj,
    ) -> Result<Expr, String> {
        Ok(self
            .0
            .clone()
            .str()
            .replace_all(
                robj_to!(Expr, pattern)?.0,
                robj_to!(Expr, value)?.0,
                robj_to!(bool, literal)?,
            )
            .into())
    }

    pub fn str_slice(&self, offset: Robj, length: Robj) -> Result<Expr, String> {
        let offset = robj_to!(i64, offset)?;
        let length = robj_to!(Option, u64, length)?;

        use pl::*;
        let function = move |s: Series| {
            let ca = s.utf8()?;
            Ok(Some(ca.str_slice(offset, length)?.into_series()))
        };

        Ok(self
            .clone()
            .0
            .map(function, GetOutput::from_type(DataType::Utf8))
            .with_fmt("str.slice")
            .into())
    }

    pub fn str_explode(&self) -> Result<Expr, String> {
        Ok(self.0.clone().str().explode().into())
    }

    pub fn str_parse_int(&self, radix: Robj, strict: Robj) -> Result<Expr, String> {
        Ok(self
            .0
            .clone()
            .str()
            .from_radix(robj_to!(u32, radix)?, robj_to!(bool, strict)?)
            .with_fmt("str.parse_int")
            .into())
    }

    pub fn bin_contains(&self, lit: Robj) -> Result<Self, String> {
        Ok(self
            .0
            .clone()
            .binary()
            .contains_literal(robj_to!(Raw, lit)?)
            .into())
    }

    pub fn bin_starts_with(&self, sub: Robj) -> Result<Self, String> {
        Ok(self
            .0
            .clone()
            .binary()
            .starts_with(robj_to!(Raw, sub)?)
            .into())
    }

    pub fn bin_ends_with(&self, sub: Robj) -> Result<Self, String> {
        Ok(self
            .0
            .clone()
            .binary()
            .ends_with(robj_to!(Raw, sub)?)
            .into())
    }

    pub fn bin_encode_hex(&self) -> Self {
        self.0
            .clone()
            .map(
                move |s| s.binary().map(|s| Some(s.hex_encode().into_series())),
                GetOutput::same_type(),
            )
            .with_fmt("binary.hex_encode")
            .into()
    }

    pub fn bin_encode_base64(&self) -> Self {
        self.0
            .clone()
            .map(
                move |s| s.binary().map(|s| Some(s.base64_encode().into_series())),
                GetOutput::same_type(),
            )
            .with_fmt("binary.base64_encode")
            .into()
    }

    pub fn bin_decode_hex(&self, strict: bool) -> Self {
        self.0
            .clone()
            .map(
                move |s| {
                    s.binary()?
                        .hex_decode(strict)
                        .map(|s| Some(s.into_series()))
                },
                GetOutput::same_type(),
            )
            .with_fmt("binary.hex_decode")
            .into()
    }

    pub fn bin_decode_base64(&self, strict: bool) -> Self {
        self.0
            .clone()
            .map(
                move |s| {
                    s.binary()?
                        .base64_decode(strict)
                        .map(|s| Some(s.into_series()))
                },
                GetOutput::same_type(),
            )
            .with_fmt("binary.base64_decode")
            .into()
    }

    pub fn struct_field_by_name(&self, name: Robj) -> Result<Expr, String> {
        Ok(self
            .0
            .clone()
            .struct_()
            .field_by_name(robj_to!(str, name)?)
            .into())
    }

    // pub fn struct_field_by_index(&self, index: i64) -> PyExpr {
    //     self.0.clone().struct_().field_by_index(index).into()
    // }

    pub fn struct_rename_fields(&self, names: Robj) -> Result<Expr, String> {
        let string_vec: Vec<String> = robj_to!(Vec, String, names)?;
        Ok(self.0.clone().struct_().rename_fields(string_vec).into())
    }

    //placed in py-polars/src/lazy/meta.rs, however extendr do not support
    //multiple export impl.
    fn meta_pop(&self) -> List {
        let exprs: Vec<pl::Expr> = self.0.clone().meta().pop();
        List::from_values(exprs.iter().map(|e| Expr(e.clone())))
    }

    fn meta_eq(&self, other: Robj) -> Result<bool, String> {
        let other = robj_to!(Expr, other)?;
        Ok(self.0 == other.0)
    }

    fn meta_roots(&self) -> Vec<String> {
        self.0
            .clone()
            .meta()
            .root_names()
            .iter()
            .map(|name| name.to_string())
            .collect()
    }

    fn meta_output_name(&self) -> Result<String, String> {
        let name = self
            .0
            .clone()
            .meta()
            .output_name()
            .map_err(|err| err.to_string())?;

        Ok(name.to_string())
    }

    fn meta_undo_aliases(&self) -> Expr {
        self.0.clone().meta().undo_aliases().into()
    }

    fn meta_has_multiple_outputs(&self) -> bool {
        self.0.clone().meta().has_multiple_outputs()
    }

    fn meta_is_regex_projection(&self) -> bool {
        self.0.clone().meta().is_regex_projection()
    }

    //the only cat ns function from dsl.rs
    fn cat_set_ordering(&self, ordering: Robj) -> Result<Expr, String> {
        let ordering = robj_to!(Map, str, ordering, |s| {
            Ok(crate::rdatatype::new_categorical_ordering(s).map_err(Rctx::Plain)?)
        })?;
        Ok(self.0.clone().cat().set_ordering(ordering).into())
    }

    // external expression function which typically starts a new expression chain
    // to avoid name space collisions in R, these static methods are not free functions
    // as in py-polars. prefix with new_ to not collide with other methods in class
    pub fn new_count() -> Expr {
        dsl::count().into()
    }

    pub fn new_first() -> Expr {
        dsl::first().into()
    }

    pub fn new_last() -> Expr {
        dsl::last().into()
    }
}

//allow proto expression that yet only are strings
//string expression will transformed into an actual expression in different contexts such as select
#[derive(Clone, Debug)]
pub enum ProtoRexpr {
    Expr(Expr),
    String(String),
}

#[extendr]
impl ProtoRexpr {
    pub fn new_str(s: &str) -> Self {
        ProtoRexpr::String(s.to_owned())
    }

    pub fn new_expr(r: &Expr) -> Self {
        ProtoRexpr::Expr(r.clone())
    }

    pub fn to_rexpr(&self, context: &str) -> Expr {
        match self {
            ProtoRexpr::Expr(r) => r.clone(),
            ProtoRexpr::String(s) => match context {
                "select" => Expr::col(s),
                _ => panic!("unknown context"),
            },
        }
    }

    fn print(&self) {
        rprintln!("{:#?}", self);
    }
}

//and array of expression or proto expressions.
#[derive(Clone, Debug)]
pub struct ProtoExprArray(pub Vec<ProtoRexpr>);
impl Default for ProtoExprArray {
    fn default() -> Self {
        Self::new()
    }
}

#[extendr]
impl ProtoExprArray {
    pub fn new() -> Self {
        ProtoExprArray(Vec::new())
    }

    pub fn push_back_str(&mut self, s: &str) {
        self.0.push(ProtoRexpr::new_str(s));
    }

    pub fn push_back_rexpr(&mut self, r: &Expr) {
        self.0.push(ProtoRexpr::new_expr(r));
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self);
    }
}

impl ProtoExprArray {
    pub fn to_vec(&self, context: &str) -> Vec<pl::Expr> {
        self.0.iter().map(|re| re.to_rexpr(context).0).collect()
    }
}

//external function as extendr-api do not allow methods returning unwrapped structs
//deprecate use method instead
pub fn pra_to_vec(pra: &ProtoExprArray, context: &str) -> Vec<pl::Expr> {
    pra.0.iter().map(|re| re.to_rexpr(context).0).collect()
}

//make options rolling options from R friendly arguments, handle conversion errors
pub fn make_rolling_options(
    window_size: &str,
    weights_robj: Nullable<Vec<f64>>,
    min_periods_float: f64,
    center: bool,
    by_null: Nullable<String>,
    closed_null: Nullable<String>,
) -> Result<pl::RollingOptions, String> {
    use crate::rdatatype::new_closed_window;

    // let weights = weights_robj.as_real_vector();
    // if weights.is_none() && !weights_robj.is_null() {
    //     return Err(String::from(
    //         "prepare rolling options: weights are neither a real vector or NULL",
    //     ));
    // };
    let weights = null_to_opt(weights_robj);
    let min_periods = try_f64_into_usize(min_periods_float)?;

    let by = null_to_opt(by_null);

    let closed_window = null_to_opt(closed_null)
        .map(|s| new_closed_window(s.as_str()))
        .transpose()?;

    Ok(pl::RollingOptions {
        window_size: pl::Duration::parse(window_size),
        weights,
        min_periods,
        center,
        by,
        closed_window,
    })
}

#[derive(Clone, Debug)]
pub struct When {
    predicate: Expr,
}

#[derive(Clone, Debug)]
pub struct WhenThen {
    predicate: Expr,
    then: Expr,
}

#[derive(Clone)]
pub struct WhenThenThen(dsl::WhenThenThen);

#[extendr]
impl WhenThenThen {
    pub fn when(&self, predicate: &Expr) -> WhenThenThen {
        Self(self.0.clone().when(predicate.0.clone()))
    }
    pub fn then(&self, expr: &Expr) -> WhenThenThen {
        Self(self.0.clone().then(expr.0.clone()))
    }
    pub fn otherwise(&self, expr: &Expr) -> Expr {
        self.0.clone().otherwise(expr.0.clone()).into()
    }

    pub fn print(&self) {
        rprintln!("Polars WhenThenThen");
    }
}

#[extendr]
impl WhenThen {
    pub fn when(&self, predicate: &Expr) -> WhenThenThen {
        let e = dsl::when(self.predicate.0.clone())
            .then(self.then.0.clone())
            .when(predicate.0.clone());
        WhenThenThen(e)
    }

    pub fn otherwise(&self, expr: &Expr) -> Expr {
        dsl::ternary_expr(
            self.predicate.0.clone(),
            self.then.0.clone(),
            expr.0.clone(),
        )
        .into()
    }

    pub fn print(&self) {
        rprintln!("{:?}", self);
    }
}

#[extendr]
impl When {
    #[allow(clippy::self_named_constructors)]
    pub fn when(predicate: &Expr) -> When {
        When {
            predicate: predicate.clone(),
        }
    }

    pub fn then(&self, expr: &Expr) -> WhenThen {
        WhenThen {
            predicate: self.predicate.clone(),
            then: expr.clone(),
        }
    }

    pub fn print(&self) {
        rprintln!("{:?}", self);
    }
}

#[extendr]
extendr_module! {
    mod dsl;
    impl Expr;
    impl ProtoExprArray;
    impl When;
    impl WhenThen;
    impl WhenThenThen;

}
