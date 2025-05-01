use crate::map::lazy::map_single;
use crate::{PlRDataType, PlRExpr, prelude::*};
use polars::lazy::dsl;
use polars::series::ops::NullBehavior;
use polars_core::chunked_array::cast::CastOptions;
use polars_core::series::IsSorted;
use savvy::{
    FunctionSexp, ListSexp, LogicalSexp, NumericScalar, NumericSexp, Result, Sexp, StringSexp,
    savvy,
};
use std::ops::Neg;

#[savvy]
impl PlRExpr {
    fn as_str(&self) -> Result<Sexp> {
        format!("{:?}", self.inner).try_into()
    }

    fn abs(&self) -> Result<Self> {
        Ok(self.inner.clone().abs().into())
    }

    fn add(&self, rhs: &PlRExpr) -> Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::Plus, rhs.inner.clone()).into())
    }

    fn sub(&self, rhs: &PlRExpr) -> Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::Minus, rhs.inner.clone()).into())
    }

    fn mul(&self, rhs: &PlRExpr) -> Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::Multiply, rhs.inner.clone()).into())
    }

    fn div(&self, rhs: &PlRExpr) -> Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::TrueDivide, rhs.inner.clone()).into())
    }

    fn rem(&self, rhs: &PlRExpr) -> Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::Modulus, rhs.inner.clone()).into())
    }

    fn floor_div(&self, rhs: &PlRExpr) -> Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::FloorDivide, rhs.inner.clone()).into())
    }

    fn neg(&self) -> Result<Self> {
        Ok(self.inner.clone().neg().into())
    }

    fn eq(&self, other: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().eq(other.inner.clone()).into())
    }

    fn eq_missing(&self, other: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().eq_missing(other.inner.clone()).into())
    }

    fn neq(&self, other: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().neq(other.inner.clone()).into())
    }

    fn neq_missing(&self, other: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().neq_missing(other.inner.clone()).into())
    }

    fn gt(&self, other: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().gt(other.inner.clone()).into())
    }

    fn gt_eq(&self, other: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().gt_eq(other.inner.clone()).into())
    }

    fn lt_eq(&self, other: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().lt_eq(other.inner.clone()).into())
    }

    fn lt(&self, other: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().lt(other.inner.clone()).into())
    }

    fn alias(&self, name: &str) -> Result<Self> {
        Ok(self.inner.clone().alias(name).into())
    }

    fn not(&self) -> Result<Self> {
        Ok(self.inner.clone().not().into())
    }

    fn is_null(&self) -> Result<Self> {
        Ok(self.inner.clone().is_null().into())
    }

    fn is_not_null(&self) -> Result<Self> {
        Ok(self.inner.clone().is_not_null().into())
    }

    fn is_infinite(&self) -> Result<Self> {
        Ok(self.inner.clone().is_infinite().into())
    }

    fn is_finite(&self) -> Result<Self> {
        Ok(self.inner.clone().is_finite().into())
    }

    fn is_nan(&self) -> Result<Self> {
        Ok(self.inner.clone().is_nan().into())
    }

    fn is_not_nan(&self) -> Result<Self> {
        Ok(self.inner.clone().is_not_nan().into())
    }

    fn min(&self) -> Result<Self> {
        Ok(self.inner.clone().min().into())
    }

    fn max(&self) -> Result<Self> {
        Ok(self.inner.clone().max().into())
    }

    fn nan_max(&self) -> Result<Self> {
        Ok(self.inner.clone().nan_max().into())
    }

    fn nan_min(&self) -> Result<Self> {
        Ok(self.inner.clone().nan_min().into())
    }

    fn mean(&self) -> Result<Self> {
        Ok(self.inner.clone().mean().into())
    }

    fn median(&self) -> Result<Self> {
        Ok(self.inner.clone().median().into())
    }

    fn sum(&self) -> Result<Self> {
        Ok(self.inner.clone().sum().into())
    }

    fn cast(&self, dtype: &PlRDataType, strict: bool, wrap_numerical: bool) -> Result<Self> {
        let dt = dtype.dt.clone();

        let options = if wrap_numerical {
            CastOptions::Overflowing
        } else if strict {
            CastOptions::Strict
        } else {
            CastOptions::NonStrict
        };

        let expr = self.inner.clone().cast_with_options(dt, options);
        Ok(expr.into())
    }

    fn sort_with(&self, descending: bool, nulls_last: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .sort(SortOptions {
                descending,
                nulls_last,
                multithreaded: true,
                maintain_order: false,
                limit: None,
            })
            .into())
    }

    fn arg_sort(&self, descending: bool, nulls_last: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .arg_sort(SortOptions {
                descending,
                nulls_last,
                multithreaded: true,
                maintain_order: false,
                limit: None,
            })
            .into())
    }

    fn sort_by(
        &self,
        by: ListSexp,
        descending: LogicalSexp,
        nulls_last: LogicalSexp,
        multithreaded: bool,
        maintain_order: bool,
    ) -> Result<Self> {
        let by = <Wrap<Vec<Expr>>>::from(by).0;
        Ok(self
            .inner
            .clone()
            .sort_by(
                by,
                SortMultipleOptions {
                    descending: descending.to_vec(),
                    nulls_last: nulls_last.to_vec(),
                    multithreaded,
                    maintain_order,
                    limit: None,
                },
            )
            .into())
    }

    fn first(&self) -> Result<Self> {
        Ok(self.inner.clone().first().into())
    }

    fn last(&self) -> Result<Self> {
        Ok(self.inner.clone().last().into())
    }

    fn filter(&self, predicate: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().filter(predicate.inner.clone()).into())
    }

    fn reverse(&self) -> Result<Self> {
        Ok(self.inner.clone().reverse().into())
    }

    fn slice(&self, offset: &PlRExpr, length: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .slice(offset.inner.clone(), length.inner.clone())
            .into())
    }

    fn over(
        &self,
        partition_by: ListSexp,
        order_by_descending: bool,
        order_by_nulls_last: bool,
        mapping_strategy: &str,
        order_by: Option<ListSexp>,
    ) -> Result<Self> {
        let partition_by = <Wrap<Vec<Expr>>>::from(partition_by).0;
        let order_by = order_by.map(|order_by| {
            (
                <Wrap<Vec<Expr>>>::from(order_by).0,
                SortOptions {
                    descending: order_by_descending,
                    nulls_last: order_by_nulls_last,
                    maintain_order: false,
                    ..Default::default()
                },
            )
        });
        let mapping_strategy = <Wrap<WindowMapping>>::try_from(mapping_strategy)?.0;

        Ok(self
            .inner
            .clone()
            .over_with_options(partition_by, order_by, mapping_strategy)
            .into())
    }

    fn and(&self, other: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().and(other.inner.clone()).into())
    }

    fn or(&self, other: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().or(other.inner.clone()).into())
    }

    fn xor(&self, other: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().xor(other.inner.clone()).into())
    }

    fn pow(&self, exponent: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().pow(exponent.inner.clone()).into())
    }

    fn diff(&self, n: &PlRExpr, null_behavior: &str) -> Result<Self> {
        let null_behavior = <Wrap<NullBehavior>>::try_from(null_behavior)?.0;
        Ok(self
            .inner
            .clone()
            .diff(n.inner.clone(), null_behavior)
            .into())
    }

    fn reshape(&self, dimensions: NumericSexp) -> Result<Self> {
        let dimensions: Vec<i64> = <Wrap<Vec<i64>>>::try_from(dimensions)?.0;
        Ok(self.inner.clone().reshape(&dimensions).into())
    }

    fn any(&self, ignore_nulls: bool) -> Result<Self> {
        Ok(self.inner.clone().any(ignore_nulls).into())
    }

    fn all(&self, ignore_nulls: bool) -> Result<Self> {
        Ok(self.inner.clone().all(ignore_nulls).into())
    }

    fn map_batches(
        &self,
        lambda: FunctionSexp,
        agg_list: bool,
        output_type: Option<&PlRDataType>,
    ) -> Result<Self> {
        map_single(self, lambda, output_type, agg_list)
    }

    fn cum_sum(&self, reverse: bool) -> Result<Self> {
        Ok(self.inner.clone().cum_sum(reverse).into())
    }

    fn cum_prod(&self, reverse: bool) -> Result<Self> {
        Ok(self.inner.clone().cum_prod(reverse).into())
    }

    fn cum_min(&self, reverse: bool) -> Result<Self> {
        Ok(self.inner.clone().cum_min(reverse).into())
    }

    fn cum_max(&self, reverse: bool) -> Result<Self> {
        Ok(self.inner.clone().cum_max(reverse).into())
    }

    fn cum_count(&self, reverse: bool) -> Result<Self> {
        Ok(self.inner.clone().cum_count(reverse).into())
    }

    fn agg_groups(&self) -> Result<Self> {
        Ok(self.inner.clone().agg_groups().into())
    }

    fn count(&self) -> Result<Self> {
        Ok(self.inner.clone().count().into())
    }

    fn arg_max(&self) -> Result<Self> {
        Ok(self.inner.clone().arg_max().into())
    }

    fn arg_min(&self) -> Result<Self> {
        Ok(self.inner.clone().arg_min().into())
    }

    fn arg_unique(&self) -> Result<Self> {
        Ok(self.inner.clone().arg_unique().into())
    }

    fn unique(&self) -> Result<Self> {
        Ok(self.inner.clone().unique().into())
    }

    fn unique_stable(&self) -> Result<Self> {
        Ok(self.inner.clone().unique_stable().into())
    }

    fn implode(&self) -> Result<Self> {
        Ok(self.inner.clone().implode().into())
    }

    fn len(&self) -> Result<Self> {
        Ok(self.inner.clone().len().into())
    }

    fn value_counts(
        &self,
        sort: bool,
        parallel: bool,
        name: &str,
        normalize: bool,
    ) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .value_counts(sort, parallel, name, normalize)
            .into())
    }

    fn unique_counts(&self) -> Result<Self> {
        Ok(self.inner.clone().unique_counts().into())
    }

    fn null_count(&self) -> Result<Self> {
        Ok(self.inner.clone().null_count().into())
    }

    fn product(&self) -> Result<Self> {
        Ok(self.inner.clone().product().into())
    }

    fn quantile(&self, quantile: &PlRExpr, interpolation: &str) -> Result<Self> {
        let interpolation = <Wrap<QuantileMethod>>::try_from(interpolation)?.0;
        Ok(self
            .inner
            .clone()
            .quantile(quantile.inner.clone(), interpolation)
            .into())
    }

    fn std(&self, ddof: NumericScalar) -> Result<Self> {
        let ddof = <Wrap<u8>>::try_from(ddof)?.0;
        Ok(self.inner.clone().std(ddof).into())
    }

    fn var(&self, ddof: NumericScalar) -> Result<Self> {
        let ddof = <Wrap<u8>>::try_from(ddof)?.0;
        Ok(self.inner.clone().var(ddof).into())
    }

    fn is_unique(&self) -> Result<Self> {
        Ok(self.inner.clone().is_unique().into())
    }

    fn is_between(&self, lower: &PlRExpr, upper: &PlRExpr, closed: &str) -> Result<Self> {
        let closed = <Wrap<ClosedInterval>>::try_from(closed)?.0;
        Ok(self
            .inner
            .clone()
            .is_between(lower.inner.clone(), upper.inner.clone(), closed)
            .into())
    }

    fn approx_n_unique(&self) -> Result<Self> {
        Ok(self.inner.clone().approx_n_unique().into())
    }

    fn n_unique(&self) -> Result<Self> {
        Ok(self.inner.clone().n_unique().into())
    }

    fn is_first_distinct(&self) -> Result<Self> {
        Ok(self.inner.clone().is_first_distinct().into())
    }

    fn is_last_distinct(&self) -> Result<Self> {
        Ok(self.inner.clone().is_last_distinct().into())
    }

    fn sin(&self) -> Result<Self> {
        Ok(self.inner.clone().sin().into())
    }

    fn cos(&self) -> Result<Self> {
        Ok(self.inner.clone().cos().into())
    }

    fn tan(&self) -> Result<Self> {
        Ok(self.inner.clone().tan().into())
    }

    fn cot(&self) -> Result<Self> {
        Ok(self.inner.clone().cot().into())
    }

    fn arcsin(&self) -> Result<Self> {
        Ok(self.inner.clone().arcsin().into())
    }

    fn arccos(&self) -> Result<Self> {
        Ok(self.inner.clone().arccos().into())
    }

    fn arctan(&self) -> Result<Self> {
        Ok(self.inner.clone().arctan().into())
    }

    fn arctan2(&self, y: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().arctan2(y.inner.clone()).into())
    }

    fn sinh(&self) -> Result<Self> {
        Ok(self.inner.clone().sinh().into())
    }

    fn cosh(&self) -> Result<Self> {
        Ok(self.inner.clone().cosh().into())
    }

    fn tanh(&self) -> Result<Self> {
        Ok(self.inner.clone().tanh().into())
    }

    fn arcsinh(&self) -> Result<Self> {
        Ok(self.inner.clone().arcsinh().into())
    }

    fn arccosh(&self) -> Result<Self> {
        Ok(self.inner.clone().arccosh().into())
    }

    fn arctanh(&self) -> Result<Self> {
        Ok(self.inner.clone().arctanh().into())
    }

    pub fn degrees(&self) -> Result<Self> {
        Ok(self.inner.clone().degrees().into())
    }

    pub fn radians(&self) -> Result<Self> {
        Ok(self.inner.clone().radians().into())
    }

    fn sign(&self) -> Result<Self> {
        Ok(self.inner.clone().sign().into())
    }

    fn is_duplicated(&self) -> Result<Self> {
        Ok(self.inner.clone().is_duplicated().into())
    }

    fn is_in(&self, expr: &PlRExpr, nulls_equal: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .is_in(expr.inner.clone(), nulls_equal)
            .into())
    }

    fn sqrt(&self) -> Result<Self> {
        Ok(self.inner.clone().sqrt().into())
    }

    fn cbrt(&self) -> Result<Self> {
        Ok(self.inner.clone().cbrt().into())
    }

    fn dot(&self, expr: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().dot(expr.inner.clone()).into())
    }

    fn cumulative_eval(
        &self,
        expr: &PlRExpr,
        min_periods: NumericScalar,
        parallel: bool,
    ) -> Result<Self> {
        let min_periods = <Wrap<usize>>::try_from(min_periods)?.0;
        Ok(self
            .inner
            .clone()
            .cumulative_eval(expr.inner.clone(), min_periods, parallel)
            .into())
    }

    fn log(&self, base: f64) -> Result<Self> {
        Ok(self.inner.clone().log(base).into())
    }

    fn log1p(&self) -> Result<Self> {
        Ok(self.inner.clone().log1p().into())
    }

    fn exp(&self) -> Result<Self> {
        Ok(self.inner.clone().exp().into())
    }

    fn mode(&self) -> Result<Self> {
        Ok(self.inner.clone().mode().into())
    }

    fn entropy(&self, base: f64, normalize: bool) -> Result<Self> {
        Ok(self.inner.clone().entropy(base, normalize).into())
    }

    fn hash(
        &self,
        seed: NumericScalar,
        seed_1: NumericScalar,
        seed_2: NumericScalar,
        seed_3: NumericScalar,
    ) -> Result<Self> {
        let seed = <Wrap<u64>>::try_from(seed)?.0;
        let seed_1 = <Wrap<u64>>::try_from(seed_1)?.0;
        let seed_2 = <Wrap<u64>>::try_from(seed_2)?.0;
        let seed_3 = <Wrap<u64>>::try_from(seed_3)?.0;
        Ok(self.inner.clone().hash(seed, seed_1, seed_2, seed_3).into())
    }

    fn pct_change(&self, n: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().pct_change(n.inner.clone()).into())
    }

    fn skew(&self, bias: bool) -> Result<Self> {
        Ok(self.inner.clone().skew(bias).into())
    }

    fn kurtosis(&self, fisher: bool, bias: bool) -> Result<Self> {
        Ok(self.inner.clone().kurtosis(fisher, bias).into())
    }

    fn peak_min(&self) -> Result<Self> {
        Ok(self.inner.clone().peak_min().into())
    }

    fn peak_max(&self) -> Result<Self> {
        Ok(self.inner.clone().peak_max().into())
    }

    fn rank(&self, method: &str, descending: bool, seed: Option<NumericScalar>) -> Result<Self> {
        let method = <Wrap<RankMethod>>::try_from(method)?.0;
        let seed: Option<u64> = match seed {
            Some(x) => Some(<Wrap<u64>>::try_from(x)?.0),
            None => None,
        };
        let options = RankOptions { method, descending };
        Ok(self.inner.clone().rank(options, seed).into())
    }

    fn hist(
        &self,
        include_category: bool,
        include_breakpoint: bool,
        bin_count: Option<NumericScalar>,
        bins: Option<&PlRExpr>,
    ) -> Result<Self> {
        let bins = bins.map(|e| e.inner.clone());
        let bin_count: Option<usize> = match bin_count {
            Some(x) => Some(<Wrap<usize>>::try_from(x)?.0),
            None => None,
        };
        Ok(self
            .inner
            .clone()
            .hist(bins, bin_count, include_category, include_breakpoint)
            .into())
    }

    fn search_sorted(&self, element: &PlRExpr, side: &str) -> Result<Self> {
        let side = <Wrap<SearchSortedSide>>::try_from(side)?.0;
        Ok(self
            .inner
            .clone()
            .search_sorted(element.inner.clone(), side)
            .into())
    }

    fn ewm_mean(
        &self,
        alpha: f64,
        adjust: bool,
        min_periods: NumericScalar,
        ignore_nulls: bool,
    ) -> Result<Self> {
        let min_periods = <Wrap<usize>>::try_from(min_periods)?.0;
        let options = EWMOptions {
            alpha,
            adjust,
            bias: false,
            min_periods,
            ignore_nulls,
        };
        Ok(self.inner.clone().ewm_mean(options).into())
    }

    fn ewm_mean_by(&self, times: &PlRExpr, half_life: &str) -> Result<Self> {
        let half_life = Duration::parse(half_life);
        Ok(self
            .inner
            .clone()
            .ewm_mean_by(times.inner.clone(), half_life)
            .into())
    }

    fn ewm_std(
        &self,
        alpha: f64,
        adjust: bool,
        bias: bool,
        min_periods: NumericScalar,
        ignore_nulls: bool,
    ) -> Result<Self> {
        let min_periods = <Wrap<usize>>::try_from(min_periods)?.0;
        let options = EWMOptions {
            alpha,
            adjust,
            bias,
            min_periods,
            ignore_nulls,
        };
        Ok(self.inner.clone().ewm_std(options).into())
    }
    fn ewm_var(
        &self,
        alpha: f64,
        adjust: bool,
        bias: bool,
        min_periods: NumericScalar,
        ignore_nulls: bool,
    ) -> Result<Self> {
        let min_periods = <Wrap<usize>>::try_from(min_periods)?.0;
        let options = EWMOptions {
            alpha,
            adjust,
            bias,
            min_periods,
            ignore_nulls,
        };
        Ok(self.inner.clone().ewm_var(options).into())
    }

    fn extend_constant(&self, value: &PlRExpr, n: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .extend_constant(value.inner.clone(), n.inner.clone())
            .into())
    }

    fn explode(&self) -> Result<Self> {
        Ok(self.inner.clone().explode().into())
    }

    fn gather(&self, idx: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().gather(idx.inner.clone()).into())
    }

    fn get(&self, idx: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().get(idx.inner.clone()).into())
    }

    fn gather_every(&self, n: NumericScalar, offset: NumericScalar) -> Result<Self> {
        let n = <Wrap<usize>>::try_from(n)?.0;
        let offset = <Wrap<usize>>::try_from(offset)?.0;
        Ok(self.inner.clone().gather_every(n, offset).into())
    }

    fn append(&self, other: &PlRExpr, upcast: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .append(other.inner.clone(), upcast)
            .into())
    }

    fn rechunk(&self) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .map(|s| Ok(Some(s.rechunk())), GetOutput::same_type())
            .into())
    }

    fn round(&self, decimals: NumericScalar, mode: &str) -> Result<Self> {
        let decimals = <Wrap<u32>>::try_from(decimals)?.0;
        let mode = <Wrap<RoundMode>>::try_from(mode)?.0;
        Ok(self.inner.clone().round(decimals, mode).into())
    }

    fn round_sig_figs(&self, digits: NumericScalar) -> Result<Self> {
        let digits = digits.as_i32()?;
        Ok(self.inner.clone().round_sig_figs(digits).into())
    }

    fn floor(&self) -> Result<Self> {
        Ok(self.inner.clone().floor().into())
    }

    fn ceil(&self) -> Result<Self> {
        Ok(self.inner.clone().ceil().into())
    }

    fn clip(&self, min: Option<&PlRExpr>, max: Option<&PlRExpr>) -> Result<Self> {
        let expr = self.inner.clone();
        let out = match (min, max) {
            (Some(min), Some(max)) => expr.clip(min.inner.clone(), max.inner.clone()),
            (Some(min), None) => expr.clip_min(min.inner.clone()),
            (None, Some(max)) => expr.clip_max(max.inner.clone()),
            (None, None) => expr,
        };
        Ok(out.into())
    }

    fn shift(&self, n: &PlRExpr, fill_value: Option<&PlRExpr>) -> Result<Self> {
        let expr = self.inner.clone();
        let out = match fill_value {
            Some(v) => expr.shift_and_fill(n.inner.clone(), v.inner.clone()),
            None => expr.shift(n.inner.clone()),
        };
        Ok(out.into())
    }

    fn fill_null(&self, expr: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().fill_null(expr.inner.clone()).into())
    }

    fn fill_null_with_strategy(
        &self,
        strategy: &str,
        limit: Option<NumericScalar>,
    ) -> Result<Self> {
        let limit: FillNullLimit = match limit {
            Some(x) => Some(<Wrap<u32>>::try_from(x)?.0),
            None => None,
        };
        let strategy = parse_fill_null_strategy(strategy, limit)?;
        Ok(self.inner.clone().fill_null_with_strategy(strategy).into())
    }

    fn fill_nan(&self, expr: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().fill_nan(expr.inner.clone()).into())
    }

    fn drop_nulls(&self) -> Result<Self> {
        Ok(self.inner.clone().drop_nulls().into())
    }

    fn drop_nans(&self) -> Result<Self> {
        Ok(self.inner.clone().drop_nans().into())
    }

    fn top_k(&self, k: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().top_k(k.inner.clone()).into())
    }

    fn top_k_by(&self, by: ListSexp, k: &PlRExpr, reverse: LogicalSexp) -> Result<Self> {
        let by = <Wrap<Vec<Expr>>>::from(by).0;
        Ok(self
            .inner
            .clone()
            .top_k_by(k.inner.clone(), by, reverse.to_vec())
            .into())
    }

    fn bottom_k(&self, k: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().bottom_k(k.inner.clone()).into())
    }

    fn bottom_k_by(&self, by: ListSexp, k: &PlRExpr, reverse: LogicalSexp) -> Result<Self> {
        let by = <Wrap<Vec<Expr>>>::from(by).0;
        Ok(self
            .inner
            .clone()
            .bottom_k_by(k.inner.clone(), by, reverse.to_vec())
            .into())
    }

    fn interpolate(&self, method: &str) -> Result<Self> {
        let method = <Wrap<InterpolationMethod>>::try_from(method)?.0;
        Ok(self.inner.clone().interpolate(method).into())
    }

    fn interpolate_by(&self, by: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().interpolate_by(by.inner.clone()).into())
    }

    fn lower_bound(&self) -> Result<Self> {
        Ok(self.inner.clone().lower_bound().into())
    }

    fn upper_bound(&self) -> Result<Self> {
        Ok(self.inner.clone().upper_bound().into())
    }

    fn cut(
        &self,
        breaks: NumericSexp,
        left_closed: bool,
        include_breaks: bool,
        labels: Option<StringSexp>,
    ) -> Result<Self> {
        let breaks: Vec<f64> = breaks.as_slice_f64().into();
        let labels = labels.map(|x| x.to_vec());
        Ok(self
            .inner
            .clone()
            .cut(breaks, labels, left_closed, include_breaks)
            .into())
    }

    fn qcut(
        &self,
        probs: NumericSexp,
        left_closed: bool,
        allow_duplicates: bool,
        include_breaks: bool,
        labels: Option<StringSexp>,
    ) -> Result<Self> {
        let probs: Vec<f64> = probs.as_slice_f64().into();
        let labels = labels.map(|x| x.to_vec());
        Ok(self
            .inner
            .clone()
            .qcut(probs, labels, left_closed, allow_duplicates, include_breaks)
            .into())
    }

    fn qcut_uniform(
        &self,
        n_bins: NumericScalar,
        left_closed: bool,
        allow_duplicates: bool,
        include_breaks: bool,
        labels: Option<StringSexp>,
    ) -> Result<Self> {
        let n_bins = <Wrap<usize>>::try_from(n_bins)?.0;
        let labels = labels.map(|x| x.to_vec());
        Ok(self
            .inner
            .clone()
            .qcut_uniform(
                n_bins,
                labels,
                left_closed,
                allow_duplicates,
                include_breaks,
            )
            .into())
    }

    fn reinterpret(&self, signed: bool) -> Result<Self> {
        Ok(self.inner.clone().reinterpret(signed).into())
    }

    fn repeat_by(&self, by: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().repeat_by(by.inner.clone()).into())
    }

    fn replace(&self, old: &PlRExpr, new: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .replace(old.inner.clone(), new.inner.clone())
            .into())
    }

    fn replace_strict(
        &self,
        old: &PlRExpr,
        new: &PlRExpr,
        default: Option<&PlRExpr>,
        return_dtype: Option<&PlRDataType>,
    ) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .replace_strict(
                old.inner.clone(),
                new.inner.clone(),
                default.map(|e| e.inner.clone()),
                return_dtype.map(|e| e.dt.clone()),
            )
            .into())
    }

    fn rle(&self) -> Result<Self> {
        Ok(self.inner.clone().rle().into())
    }

    fn rle_id(&self) -> Result<Self> {
        Ok(self.inner.clone().rle_id().into())
    }

    fn shuffle(&self, seed: Option<NumericScalar>) -> Result<Self> {
        let seed: Option<u64> = match seed {
            Some(x) => Some(<Wrap<u64>>::try_from(x)?.0),
            None => None,
        };
        Ok(self.inner.clone().shuffle(seed).into())
    }

    fn sample_n(
        &self,
        n: &PlRExpr,
        with_replacement: bool,
        shuffle: bool,
        seed: Option<NumericScalar>,
    ) -> Result<Self> {
        let seed: Option<u64> = match seed {
            Some(x) => Some(<Wrap<u64>>::try_from(x)?.0),
            None => None,
        };
        Ok(self
            .inner
            .clone()
            .sample_n(n.inner.clone(), with_replacement, shuffle, seed)
            .into())
    }

    fn sample_frac(
        &self,
        frac: &PlRExpr,
        with_replacement: bool,
        shuffle: bool,
        seed: Option<NumericScalar>,
    ) -> Result<Self> {
        let seed: Option<u64> = match seed {
            Some(x) => Some(<Wrap<u64>>::try_from(x)?.0),
            None => None,
        };
        Ok(self
            .inner
            .clone()
            .sample_frac(frac.inner.clone(), with_replacement, shuffle, seed)
            .into())
    }

    fn shrink_dtype(&self) -> Result<Self> {
        Ok(self.inner.clone().shrink_dtype().into())
    }

    fn set_sorted_flag(&self, descending: bool) -> Result<Self> {
        let is_sorted = if descending {
            IsSorted::Descending
        } else {
            IsSorted::Ascending
        };
        Ok(self.inner.clone().set_sorted_flag(is_sorted).into())
    }

    fn to_physical(&self) -> Result<Self> {
        Ok(self.inner.clone().to_physical().into())
    }

    fn rolling(
        &self,
        index_column: &str,
        period: &str,
        offset: &str,
        closed: &str,
    ) -> Result<Self> {
        let closed = <Wrap<ClosedWindow>>::try_from(closed)?.0;
        let options = RollingGroupOptions {
            index_column: index_column.into(),
            period: Duration::parse(period),
            offset: Duration::parse(offset),
            closed_window: closed,
        };

        Ok(self.inner.clone().rolling(options).into())
    }

    fn exclude(&self, columns: StringSexp) -> Result<Self> {
        let columns = columns.to_vec();
        Ok(self.inner.clone().exclude(columns).into())
    }

    fn exclude_dtype(&self, dtypes: ListSexp) -> Result<Self> {
        let dtypes = <Wrap<Vec<DataType>>>::try_from(dtypes)?.0;
        Ok(self.inner.clone().exclude_dtype(dtypes).into())
    }
}
