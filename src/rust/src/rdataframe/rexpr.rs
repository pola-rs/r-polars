use super::rseries::Series;
use crate::rdatatype::new_quantile_interpolation_option;
use crate::rdatatype::{DataType, DataTypeVector};
use crate::utils::extendr_concurrent::{ParRObj, ThreadCom};
use crate::utils::parse_fill_null_strategy;
use crate::utils::wrappers::null_to_opt;
use crate::utils::{r_error_list, r_ok_list, r_result_list};
use crate::utils::{try_f64_into_u32, try_f64_into_usize};
use crate::CONFIG;
use extendr_api::{extendr, prelude::*, rprintln, Deref, DerefMut, Rinternals};
use polars::chunked_array::object::SortOptions;
use polars::lazy::dsl;
use polars::prelude::GetOutput;
use polars::prelude::{self as pl};
use std::ops::{Add, Div, Mul, Sub};

#[derive(Clone, Debug)]
#[extendr]
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

            (x, 1) => Err(format!(
                "$lit(val): minipolars not yet support rtype {:?}",
                x
            )),
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
                |s| Ok(s.to_physical_repr().into_owned()),
                GetOutput::map_dtype(|dt| dt.to_physical()),
            )
            .with_fmt("to_physical")
            .into()
    }

    pub fn cast(&self, data_type: &DataType, strict: bool) -> Self {
        let dt = data_type.0.clone();
        if strict {
            self.0.clone().strict_cast(dt)
        } else {
            self.0.clone().cast(dt)
        }
        .into()
    }

    pub fn sort(&self, descending: bool, nulls_last: bool) -> Self {
        self.clone()
            .0
            .sort_with(SortOptions {
                descending,
                nulls_last,
            })
            .into()
    }

    pub fn arg_sort(&self, descending: bool, nulls_last: bool) -> Self {
        self.clone()
            .0
            .arg_sort(SortOptions {
                descending,
                nulls_last,
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

    pub fn search_sorted(&self, element: &Expr) -> Self {
        self.0.clone().search_sorted(element.0.clone()).into()
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
        let lmt = null_to_opt(limit).map(|x| x as u32);

        let strat_result = parse_fill_null_strategy(strategy, lmt);

        if let Ok(strat) = strat_result {
            let result: pl::PolarsResult<Expr> = Ok(self
                .0
                .clone()
                .apply(move |s| s.fill_null(strat), GetOutput::same_type())
                .with_fmt("fill_null_with_strategy")
                .into());

            r_result_list(result)
        } else {
            if let Err(err) = strat_result {
                r_error_list(err)
            } else {
                unreachable!("yep")
            }
        }
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

    pub fn quantile(&self, quantile: f64, interpolation: &str) -> List {
        let res = new_quantile_interpolation_option(interpolation)
            .map(|intpl| Expr(self.clone().0.quantile(quantile, intpl)));
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
                    self.0
                        .clone()
                        .map(
                            move |s: Series| Ok(s.0.take_every(n)),
                            GetOutput::same_type(),
                        )
                        .with_fmt("take_every"),
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
        let function = move |s: pl::Series| reinterpret(&s, signed);
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

    pub fn interpolate(&self) -> Expr {
        self.0.clone().interpolate().into()
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
            let interpolation = new_quantile_interpolation_option(interpolation)
                .map_err(|err| format!("rolling_quantile: {}", err))?;
            Ok(Expr(self.0.clone().rolling_quantile(
                quantile,
                interpolation,
                opts,
            )))
        });
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

    pub fn pow(&self, exponent: &Expr) -> Self {
        self.0.clone().pow(exponent.0.clone()).into()
    }

    pub fn repeat_by(&self, by: &Expr) -> Expr {
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

    pub fn list(&self) -> Self {
        self.clone().0.list().into()
    }

    pub fn abs(&self) -> Self {
        self.0.clone().abs().into()
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

    pub fn slice(&self, offset: &Expr, length: &Expr) -> Self {
        self.0
            .clone()
            .slice(offset.0.clone(), length.0.clone())
            .into()
    }

    pub fn append(&self, other: &Expr, upcast: bool) -> Self {
        self.0.clone().append(other.0.clone(), upcast).into()
    }

    pub fn rechunk(&self) -> Self {
        self.0
            .clone()
            .map(|s| Ok(s.rechunk()), GetOutput::same_type())
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

    //expr "funnies"
    pub fn over(&self, proto_exprs: &ProtoExprArray) -> Self {
        let ve = pra_to_vec(proto_exprs, "select");
        self.0.clone().over(ve).into()
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    pub fn map(&self, lambda: Robj, output_type: Nullable<&DataType>, agg_list: bool) -> Self {
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
            Ok(s)
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

        let f = move |name: &str| -> String {
            let robj = probj.clone().0;
            let rfun = robj
                .as_function()
                .expect("internal error: this is not an R function");

            let newname_robj = rfun
                .call(pairlist!(name))
                .expect("user function raised an error");
            newname_robj
                .as_str()
                .expect("R function return value was not a string")
                .to_string()
        };

        self.clone().0.map_alias(f).into()
    }

    fn suffix(&self, suffix: String) -> Self {
        self.0.clone().suffix(suffix.as_str()).into()
    }

    fn prefix(&self, prefix: String) -> Self {
        self.0.clone().prefix(prefix.as_str()).into()
    }

    // fn to_field(&self, df: &DataFrame) {
    //     let ctxt = polars::prelude::Context::Default;
    //     let res = self.0.to_field(&df.0.schema(), ctxt);
    //     res.unwrap();
    // }
}

//allow proto expression that yet only are strings
//string expression will transformed into an actual expression in different contexts such as select
#[derive(Clone, Debug)]
#[extendr]
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
#[extendr]
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
