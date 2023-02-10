use super::rseries::Series;
use crate::rdatatype::literal_to_any_value;
use crate::rdatatype::new_null_behavior;
use crate::rdatatype::new_quantile_interpolation_option;
use crate::rdatatype::new_rank_method;

use crate::rdatatype::robj_to_timeunit;

use crate::rdatatype::{DataTypeVector, RPolarsDataType};
use crate::utils::extendr_concurrent::{ParRObj, ThreadCom};
use crate::utils::parse_fill_null_strategy;
use crate::utils::wrappers::null_to_opt;
use crate::utils::{r_error_list, r_ok_list, r_result_list};
use crate::utils::{try_f64_into_i64, try_f64_into_u32, try_f64_into_usize};
use crate::CONFIG;
use extendr_api::{extendr, prelude::*, rprintln, Deref, DerefMut, Rinternals};

use pl::PolarsError as pl_error;
use polars::chunked_array::object::SortOptions;
use polars::error::ErrString as pl_err_string;
use polars::lazy::dsl;
use polars::prelude::DurationMethods;
use polars::prelude::GetOutput;
use polars::prelude::IntoSeries;
use polars::prelude::TemporalMethods;
use polars::prelude::{self as pl};
use std::ops::{Add, Div, Mul, Sub};

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
    pub fn lit(robj: Robj) -> List {
        let rtype = robj.rtype();
        let rlen = robj.len();
        let err_msg = "NA not allowed use NULL";
        let expr_result = match (rtype, rlen) {
            (Rtype::Null, _) => Ok(dsl::lit(pl::NULL)),
            (Rtype::Integers, 1) => {
                let opt_val = robj.as_integer();
                if let Some(val) = opt_val.clone() {
                    Ok(dsl::lit(val))
                } else {
                    if robj.is_na() {
                        Ok(dsl::lit(pl::NULL).cast(pl::DataType::Int32))
                    } else {
                        Err(err_msg.into())
                    }
                }
            }
            (Rtype::Doubles, 1) => {
                let opt_val = robj.as_real();
                if let Some(val) = opt_val.clone() {
                    Ok(dsl::lit(val))
                } else {
                    if robj.is_na() {
                        Ok(dsl::lit(pl::NULL).cast(pl::DataType::Float64))
                    } else {
                        Err(err_msg.into())
                    }
                }
            }
            (Rtype::Strings, 1) => {
                let opt_val = robj.as_str();
                if let Some(val) = opt_val.clone() {
                    Ok(dsl::lit(val))
                } else {
                    if robj.is_na() {
                        Ok(dsl::lit(pl::NULL).cast(pl::DataType::Utf8))
                    } else {
                        Err(err_msg.into())
                    }
                }
            }
            (Rtype::Logicals, 1) => {
                let opt_val = robj.as_bool();
                if let Some(val) = opt_val.clone() {
                    Ok(dsl::lit(val))
                } else {
                    if robj.is_na() {
                        Ok(dsl::lit(pl::NULL).cast(pl::DataType::Boolean))
                    } else {
                        Err(err_msg.into())
                    }
                }
            }
            (Rtype::ExternalPtr, 1) => {
                let x = match () {
                    _ if robj.inherits("Series") => {
                        let s: Series = unsafe { &mut *robj.external_ptr_addr::<Series>() }.clone();
                        pl::lit(s.0)
                    }
                    _ => {
                        dbg!(&robj);
                        todo!("cannot yet handle this externalptr");
                    }
                };
                Ok(x)
            }

            (x, 1) => Err(format!("$lit(val): rpolars not yet support rtype {:?}", x)),
            (_, n) => Err(format!(
                "$lit(val), literals mush have length one, not length: {:?}",
                n
            )),
        }
        .map(|ok| Expr(ok));

        r_result_list(expr_result)
    }

    //expr binary comparisons
    pub fn gt(&self, other: &Expr) -> Self {
        self.0.clone().gt(other.0.clone()).into()
    }

    pub fn gt_eq(&self, other: &Expr) -> Self {
        self.0.clone().gt_eq(other.0.clone()).into()
    }

    pub fn lt(&self, other: &Expr) -> Self {
        self.0.clone().lt(other.0.clone()).into()
    }

    pub fn lt_eq(&self, other: &Expr) -> Self {
        self.0.clone().lt_eq(other.0.clone()).into()
    }

    pub fn neq(&self, other: &Expr) -> Self {
        self.0.clone().neq(other.0.clone()).into()
    }

    pub fn eq(&self, other: &Expr) -> Self {
        self.0.clone().eq(other.0.clone()).into()
    }

    //logical operators
    fn and(&self, other: &Expr) -> Self {
        self.0.clone().and(other.0.clone()).into()
    }

    fn or(&self, other: &Expr) -> Self {
        self.0.clone().or(other.0.clone()).into()
    }

    fn xor(&self, other: &Expr) -> Self {
        self.0.clone().xor(other.0.clone()).into()
    }

    fn is_in(&self, other: &Expr) -> Self {
        self.0.clone().is_in(other.0.clone()).into()
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

    pub fn top_k(&self, k: f64, reverse: bool) -> Self {
        self.0.clone().top_k(k as usize, reverse).into()
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

    pub fn sort_by(&self, by: &ProtoExprArray, reverse: Robj) -> List {
        let rev: Vec<bool> = if let Some(lgl_itr) = reverse.as_logical_iter() {
            lgl_itr.map(|x| x.is_true()).collect()
        } else {
            return r_error_list("reverse argument must be a logical vector");
        };
        let by = by.to_vec("select");
        let expr = Expr(self.clone().0.sort_by(by, rev));
        r_ok_list(expr)
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
        let res = || -> std::result::Result<Expr, String> {
            let limit = null_to_opt(limit)
                .map(|lim| try_f64_into_usize(lim, false))
                .transpose()?;
            let limit: pl::FillNullLimit = limit.map(|x| x as u32).into();

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

    pub fn std(&self, ddof: u8) -> Self {
        self.0.clone().std(ddof).into()
    }

    pub fn var(&self, ddof: u8) -> Self {
        self.clone().0.var(ddof).into()
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

        let result = try_f64_into_usize(n, true)
            .map_err(|err| format!("Invalid n argument in take_every: {}", err))
            .map(|n| {
                Expr(
                    self.clone()
                        .0
                        .map(
                            move |s: Series| Ok(Some(s.take_every(n))),
                            GetOutput::same_type(),
                        )
                        .with_fmt("take_every")
                        .into(),
                )
            });

        r_result_list(result)
    }

    pub fn hash(&self, seed: f64, seed_1: f64, seed_2: f64, seed_3: f64) -> List {
        let vec_u64_result: std::result::Result<Vec<u64>, String> = [seed, seed_1, seed_2, seed_3]
            .iter()
            .map(|x| try_f64_into_usize(*x, false).map(|val| val as u64))
            .collect();
        r_result_list(
            vec_u64_result
                .map(|v| Expr(self.0.clone().hash(v[0], v[1], v[2], v[3])))
                .map_err(|err| format!("in hash(): {}", err)),
        )
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
            try_f64_into_usize(window_size_f, false).map(|ws| {
                Expr(self.0.clone().rolling_apply_float(ws, move |ca| {
                    ca.clone().into_series().skew(bias).unwrap()
                }))
            });
        r_result_list(expr)
    }

    pub fn abs(&self) -> Self {
        self.0.clone().abs().into()
    }

    fn rank(&self, method: &str, reverse: bool) -> List {
        let expr_res = new_rank_method(method)
            .map(|rank_method| {
                let options = pl::RankOptions {
                    method: rank_method,
                    descending: reverse,
                };
                Expr(self.0.clone().rank(options))
            })
            .map_err(|err| format!("rank: {}", err));

        r_result_list(expr_res)
    }

    fn diff(&self, n_float: f64, null_behavior: &str) -> List {
        let expr_res = || -> std::result::Result<Expr, String> {
            Ok(Expr(self.0.clone().diff(
                try_f64_into_usize(n_float, false)?,
                new_null_behavior(null_behavior)?,
            )))
        }()
        .map_err(|err| format!("diff: {}", err));
        r_result_list(expr_res)
    }

    fn pct_change(&self, n_float: f64) -> List {
        let expr_res = try_f64_into_usize(n_float, false)
            .map(|n_usize| Expr(self.0.clone().pct_change(n_usize)))
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
        let expr_res = || -> std::result::Result<Expr, String> {
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
        let expr_res = || -> std::result::Result<Expr, String> {
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
        let expr_res = || -> std::result::Result<Expr, String> {
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
        let dims_result: std::result::Result<Vec<i64>, String> =
            dims.iter().map(|x| try_f64_into_i64(*x)).collect();
        let expr_result = dims_result
            .map(|dims| Expr(self.0.clone().reshape(&dims[..])))
            .map_err(|err| format!("reshape: {}", err));
        r_result_list(expr_result)
    }

    pub fn shuffle(&self, seed: f64) -> List {
        let seed_res =
            try_f64_into_usize(seed, false).map(|s| Expr(self.0.clone().shuffle(Some(s as u64))));
        r_result_list(seed_res)
    }

    pub fn sample_n(&self, n: f64, with_replacement: bool, shuffle: bool, seed: f64) -> List {
        let expr_result = || -> std::result::Result<Expr, String> {
            let seed = try_f64_into_usize(seed, false)?;
            let n = try_f64_into_usize(n, false)?;
            Ok(self
                .0
                .clone()
                .sample_n(n, with_replacement, shuffle, Some(seed as u64))
                .into())
        }();
        r_result_list(expr_result)
    }

    pub fn sample_frac(&self, frac: f64, with_replacement: bool, shuffle: bool, seed: f64) -> List {
        let expr_result = || -> std::result::Result<Expr, String> {
            let seed = try_f64_into_usize(seed, false)?;
            Ok(self
                .0
                .clone()
                .sample_frac(frac, with_replacement, shuffle, Some(seed as u64))
                .into())
        }();
        r_result_list(expr_result)
    }

    pub fn ewm_mean(&self, alpha: f64, adjust: bool, min_periods: f64, ignore_nulls: bool) -> List {
        let expr_result = || -> std::result::Result<Expr, String> {
            let min_periods = try_f64_into_usize(min_periods, false)?;
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
        let expr_result = || -> std::result::Result<Expr, String> {
            let min_periods = try_f64_into_usize(min_periods, false)?;
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
        let expr_result = || -> std::result::Result<Expr, String> {
            let min_periods = try_f64_into_usize(min_periods, false)?;
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
        let expr_res = || -> std::result::Result<Expr, String> {
            let av = match value.clone().0 {
                pl::Expr::Literal(ma) => literal_to_any_value(ma),
                ma => Err(format!("value [{:?}] was not a literal:", ma)),
            }?;
            let n = try_f64_into_usize(n, false)?;

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

    pub fn extend_expr(&self, value: &Expr, n: &Expr) -> Self {
        let v = value.clone();
        let n = Expr(n.0.clone().strict_cast(pl::DataType::UInt64));

        Expr(
            self.0
                .clone()
                .apply(
                    move |s| Series(s).extend_expr(&v, &n).map(|s| s.0).map(Some),
                    GetOutput::same_type(),
                )
                .with_fmt("extend"),
        )
    }

    pub fn rep(&self, n: f64, rechunk: bool) -> List {
        match try_f64_into_usize(n, false) {
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
        r_result_list(try_f64_into_usize(min_periods, false).map(|min_p| {
            Expr(
                self.0
                    .clone()
                    .cumulative_eval(expr.0.clone(), min_p, parallel),
            )
        }))
    }

    pub fn list(&self) -> Self {
        self.clone().0.list().into()
    }

    pub fn shrink_dtype(&self) -> Self {
        self.0.clone().shrink_dtype().into()
    }

    //arr/list methods

    fn arr_lengths(&self) -> Self {
        self.0.clone().arr().lengths().into()
    }

    pub fn arr_contains(&self, other: &Expr) -> Expr {
        self.0.clone().arr().contains(other.0.clone()).into()
    }

    fn lst_max(&self) -> Self {
        self.0.clone().arr().max().into()
    }

    fn lst_min(&self) -> Self {
        self.0.clone().arr().min().into()
    }

    fn lst_sum(&self) -> Self {
        self.0.clone().arr().sum().with_fmt("arr.sum").into()
    }

    fn lst_mean(&self) -> Self {
        self.0.clone().arr().mean().with_fmt("arr.mean").into()
    }

    fn lst_sort(&self, reverse: bool) -> Self {
        self.0
            .clone()
            .arr()
            .sort(SortOptions {
                descending: reverse,
                ..Default::default()
            })
            .with_fmt("arr.sort")
            .into()
    }

    fn lst_reverse(&self) -> Self {
        self.0
            .clone()
            .arr()
            .reverse()
            .with_fmt("arr.reverse")
            .into()
    }

    fn lst_unique(&self) -> Self {
        self.0.clone().arr().unique().with_fmt("arr.unique").into()
    }

    fn lst_take(&self, index: &Expr, null_on_oob: bool) -> Self {
        self.0
            .clone()
            .arr()
            .take(index.0.clone(), null_on_oob)
            .into()
    }

    fn lst_get(&self, index: &Expr) -> Self {
        self.0.clone().arr().get(index.clone().0).into()
    }

    fn lst_join(&self, separator: &str) -> Self {
        self.0.clone().arr().join(separator).into()
    }

    fn lst_arg_min(&self) -> Self {
        self.0.clone().arr().arg_min().into()
    }

    fn lst_arg_max(&self) -> Self {
        self.0.clone().arr().arg_max().into()
    }

    fn lst_diff(&self, n: f64, null_behavior: &str) -> List {
        let expr_res = || -> std::result::Result<Expr, String> {
            Ok(Expr(self.0.clone().arr().diff(
                try_f64_into_usize(n, false)?,
                new_null_behavior(null_behavior)?,
            )))
        }()
        .map_err(|err| format!("arr.diff: {}", err));
        r_result_list(expr_res)
    }

    fn lst_shift(&self, periods: f64) -> List {
        let expr_res = || -> std::result::Result<Expr, String> {
            Ok(Expr(self.0.clone().arr().shift(try_f64_into_i64(periods)?)))
        }()
        .map_err(|err| format!("arr.shift: {}", err));
        r_result_list(expr_res)
    }

    fn lst_slice(&self, offset: &Expr, length: Nullable<&Expr>) -> Self {
        let length = match null_to_opt(length) {
            Some(i) => i.0.clone(),
            None => dsl::lit(i64::MAX),
        };
        self.0.clone().arr().slice(offset.0.clone(), length).into()
    }

    fn lst_eval(&self, expr: &Expr, parallel: bool) -> Self {
        use pl::*;
        self.0.clone().arr().eval(expr.0.clone(), parallel).into()
    }

    fn lst_to_struct(&self, width_strat: &str, name_gen: Nullable<Robj>, upper_bound: f64) -> List {
        use crate::rdatatype::new_width_strategy;
        use crate::utils::extendr_concurrent::ParRObj;
        use pl::NamedFrom;
        // TODO improve extendr_concurrent to support other closures thatn |Series|->Series
        // here a usize is wrapped in Series
        let name_gen = if let Some(robj) = null_to_opt(name_gen) {
            let probj: ParRObj = robj.clone().into();
            let x = Some(pl::Arc::new(move |idx: usize| {
                let thread_com = ThreadCom::from_global(&CONFIG);
                let s = pl::Series::new("", &[idx as u64]);
                thread_com.send((probj.clone(), s));
                let s = thread_com.recv();
                s.0.name().to_string()
            }) as NameGenerator);
            x
        } else {
            None
        };

        //resolve usize from f64 and stategy from str
        let res = || -> std::result::Result<Expr, String> {
            let ub = try_f64_into_usize(upper_bound, false)?;
            let strat = new_width_strategy(width_strat)?;
            Ok(Expr(self.0.clone().arr().to_struct(strat, name_gen, ub)))
        }();

        let res = res.map_err(|err| format!("in to_struct: {}", err));

        r_result_list(res)
    }

    pub fn str_parse_date(
        &self,
        fmt: Nullable<String>,
        strict: bool,
        exact: bool,
        cache: bool,
    ) -> Self {
        self.0
            .clone()
            .str()
            .strptime(pl::StrpTimeOptions {
                date_dtype: pl::DataType::Date,
                fmt: null_to_opt(fmt),
                strict,
                exact,
                cache,
                tz_aware: false,
                utc: false,
            })
            .into()
    }

    pub fn str_parse_datetime(
        &self,
        fmt: Nullable<String>,
        strict: bool,
        exact: bool,
        cache: bool,
        tz_aware: bool,
        utc: bool,
        tu: Nullable<Robj>,
    ) -> List {
        let res = || -> std::result::Result<Expr, String> {
            let tu = null_to_opt(tu).map(|tu| robj_to_timeunit(tu)).transpose()?;
            let fmt = null_to_opt(fmt);
            let result_tu = match (&fmt, tu) {
                (_, Some(tu)) => tu,
                (Some(fmt), None) => {
                    if fmt.contains("%.9f")
                        || fmt.contains("%9f")
                        || fmt.contains("%f")
                        || fmt.contains("%.f")
                    {
                        pl::TimeUnit::Nanoseconds
                    } else if fmt.contains("%.3f") || fmt.contains("%3f") {
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
                .strptime(pl::StrpTimeOptions {
                    date_dtype: pl::DataType::Datetime(result_tu, None),
                    fmt,
                    strict,
                    exact,
                    cache,
                    tz_aware,
                    utc,
                })
                .into())
        }();
        r_result_list(res)
    }

    pub fn str_parse_time(
        &self,
        fmt: Nullable<String>,
        strict: bool,
        exact: bool,
        cache: bool,
    ) -> Self {
        self.0
            .clone()
            .str()
            .strptime(pl::StrpTimeOptions {
                date_dtype: pl::DataType::Time,
                fmt: null_to_opt(fmt),
                strict,
                exact,
                cache,
                tz_aware: false,
                utc: false,
            })
            .into()
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

    pub fn dt_with_time_zone(&self, tz: String) -> Self {
        self.0.clone().dt().with_time_zone(tz).into()
    }

    pub fn dt_cast_time_zone(&self, tz: Nullable<String>) -> Self {
        self.0.clone().dt().cast_time_zone(tz.into_option()).into()
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

    pub fn pow(&self, exponent: &Expr) -> Self {
        self.0.clone().pow(exponent.0.clone()).into()
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
        let res = try_f64_into_u32(decimals, false)
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

    pub fn head(&self, n: f64) -> List {
        let res = try_f64_into_usize(n, false)
            .map_err(|err| format!("in head: {}", err))
            .map(|n| Expr(self.0.clone().head(Some(n))));
        r_result_list(res)
    }

    pub fn tail(&self, n: f64) -> List {
        let res = try_f64_into_usize(n, false)
            .map_err(|err| format!("in tail: {}", err))
            .map(|n| Expr(self.0.clone().tail(Some(n))));
        r_result_list(res)
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
    pub fn add(&self, other: &Expr) -> Self {
        self.0.clone().add(other.0.clone()).into()
    }

    //binary arithmetic expressions
    pub fn sub(&self, other: &Expr) -> Self {
        self.0.clone().sub(other.0.clone()).into()
    }

    pub fn mul(&self, other: &Expr) -> Self {
        self.0.clone().mul(other.0.clone()).into()
    }

    pub fn div(&self, other: &Expr) -> Self {
        self.0.clone().div(other.0.clone()).into()
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
            let thread_com = ThreadCom::from_global(&CONFIG);

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

    pub fn is_unique(&self) -> Self {
        self.clone().0.is_unique().into()
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
                let es = pl_err_string::Owned(format!(
                    "in map_alias: user function raised this error: {:?}",
                    err
                ));
                pl_error::ComputeError(es)
            })?;

            newname_robj
                .as_str()
                .ok_or_else(|| {
                    let es = pl_err_string::Owned(format!(
                        "in map_alias: R function return value was not a string"
                    ));
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
        use pl::*;
        let function = |s: Series| {
            let ca = s.utf8()?;
            Ok(Some(ca.str_n_chars().into_series()))
        };
        self.clone()
            .0
            .map(function, GetOutput::from_type(pl::DataType::UInt32))
            .with_fmt("str.n_chars")
            .into()
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
                "select" => Expr::col(&s),
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
) -> std::result::Result<pl::RollingOptions, String> {
    use crate::rdatatype::new_closed_window;

    // let weights = weights_robj.as_real_vector();
    // if weights.is_none() && !weights_robj.is_null() {
    //     return Err(String::from(
    //         "prepare rolling options: weights are neither a real vector or NULL",
    //     ));
    // };
    let weights = null_to_opt(weights_robj);
    let min_periods = try_f64_into_usize(min_periods_float, false)?;

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

extendr_module! {
    mod rexpr;
    impl Expr;
    impl ProtoExprArray;

}
