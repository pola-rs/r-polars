use crate::{PlRExpr, prelude::*};
use polars::{prelude::SetOperation, series::ops::NullBehavior};
use savvy::{NumericScalar, Result, savvy};

#[savvy]
impl PlRExpr {
    fn list_len(&self) -> Result<Self> {
        Ok(self.inner.clone().list().len().into())
    }

    pub fn list_contains(&self, other: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .list()
            .contains(other.inner.clone())
            .into())
    }

    fn list_max(&self) -> Result<Self> {
        Ok(self.inner.clone().list().max().into())
    }

    fn list_min(&self) -> Result<Self> {
        Ok(self.inner.clone().list().min().into())
    }

    fn list_sum(&self) -> Result<Self> {
        Ok(self.inner.clone().list().sum().into())
    }

    fn list_mean(&self) -> Result<Self> {
        Ok(self.inner.clone().list().mean().into())
    }

    fn list_sort(&self, descending: bool, nulls_last: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .list()
            .sort(
                SortOptions::default()
                    .with_order_descending(descending)
                    .with_nulls_last(nulls_last),
            )
            .into())
    }

    fn list_reverse(&self) -> Result<Self> {
        Ok(self.inner.clone().list().reverse().into())
    }

    fn list_unique(&self, maintain_order: bool) -> Result<Self> {
        let e = self.inner.clone();
        let out = if maintain_order {
            e.list().unique_stable().into()
        } else {
            e.list().unique().into()
        };
        Ok(out)
    }

    fn list_n_unique(&self) -> Result<Self> {
        Ok(self.inner.clone().list().n_unique().into())
    }

    fn list_gather(&self, index: &PlRExpr, null_on_oob: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .list()
            .gather(index.inner.clone(), null_on_oob)
            .into())
    }

    fn list_gather_every(&self, n: &PlRExpr, offset: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .list()
            .gather_every(n.inner.clone(), offset.inner.clone())
            .into())
    }

    fn list_get(&self, index: &PlRExpr, null_on_oob: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .list()
            .get(index.inner.clone(), null_on_oob)
            .into())
    }

    fn list_join(&self, separator: &PlRExpr, ignore_nulls: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .list()
            .join(separator.inner.clone(), ignore_nulls)
            .into())
    }

    fn list_arg_min(&self) -> Result<Self> {
        Ok(self.inner.clone().list().arg_min().into())
    }

    fn list_arg_max(&self) -> Result<Self> {
        Ok(self.inner.clone().list().arg_max().into())
    }

    fn list_diff(&self, n: NumericScalar, null_behavior: &str) -> Result<Self> {
        let n = <Wrap<i64>>::try_from(n)?.0;
        let null_behavior = <Wrap<NullBehavior>>::try_from(null_behavior)?.0;

        Ok(self.inner.clone().list().diff(n, null_behavior).into())
    }

    fn list_shift(&self, periods: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .list()
            .shift(periods.inner.clone())
            .into())
    }

    fn list_slice(&self, offset: &PlRExpr, length: Option<&PlRExpr>) -> Result<Self> {
        let length = match length {
            Some(i) => i.inner.clone(),
            None => lit(i64::MAX),
        };
        Ok(self
            .inner
            .clone()
            .list()
            .slice(offset.inner.clone(), length)
            .into())
    }

    fn list_eval(&self, expr: &PlRExpr, parallel: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .list()
            .eval(expr.inner.clone(), parallel)
            .into())
    }

    // fn list_to_struct(
    //     &self,
    //     n_field_strategy: &str,
    //     fields: Robj,
    //     upper_bound: Robj,
    // ) -> Result<Self> {
    //     let n_field_strategy = <Wrap<ListToStructWidthStrategy>>::try_from(n_field_strategy)?.0;
    //     let fields = robj_to!(Option, Robj, fields)?.map(|robj| {
    //         let par_fn: ParRObj = robj.into();
    //         let f: Arc<(dyn Fn(usize) -> pl::PlSmallStr + Send + Sync + 'static)> =
    //             pl::Arc::new(move |idx: usize| {
    //                 let thread_com = ThreadCom::from_global(&CONFIG);
    //                 thread_com.send(RFnSignature::FnF64ToString(par_fn.clone(), idx as f64));
    //                 let s = thread_com.recv().unwrap_string();
    //                 let s: pl::PlSmallStr = s.into();
    //                 s
    //             });
    //         f
    //     });
    //     let ub = robj_to!(usize, upper_bound)?;
    //     Ok(RPolarsExpr(self.inner.clone().list().to_struct(
    //         n_field_strategy,
    //         fields,
    //         ub,
    //     )))
    // }

    fn list_all(&self) -> Result<Self> {
        Ok(self.inner.clone().list().all().into())
    }

    fn list_any(&self) -> Result<Self> {
        Ok(self.inner.clone().list().any().into())
    }

    fn list_set_operation(&self, other: &PlRExpr, operation: &str) -> Result<Self> {
        let operation = <Wrap<SetOperation>>::try_from(operation)?.0;
        let e = self.inner.clone().list();
        Ok(match operation {
            SetOperation::Intersection => e.set_intersection(other.inner.clone()),
            SetOperation::Difference => e.set_difference(other.inner.clone()),
            SetOperation::Union => e.union(other.inner.clone()),
            SetOperation::SymmetricDifference => e.set_symmetric_difference(other.inner.clone()),
        }
        .into())
    }

    pub fn list_sample_n(
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
            .list()
            .sample_n(n.inner.clone(), with_replacement, shuffle, seed)
            .into())
    }

    pub fn list_sample_frac(
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
            .list()
            .sample_fraction(frac.inner.clone(), with_replacement, shuffle, seed)
            .into())
    }

    fn list_median(&self) -> Result<Self> {
        Ok(self.inner.clone().list().median().into())
    }

    fn list_std(&self, ddof: NumericScalar) -> Result<Self> {
        let ddof = <Wrap<u8>>::try_from(ddof)?.0;
        Ok(self.inner.clone().list().std(ddof).into())
    }

    fn list_var(&self, ddof: NumericScalar) -> Result<Self> {
        let ddof = <Wrap<u8>>::try_from(ddof)?.0;
        Ok(self.inner.clone().list().var(ddof).into())
    }

    fn list_to_array(&self, width: NumericScalar) -> Result<Self> {
        let width = <Wrap<usize>>::try_from(width)?.0;
        Ok(self.inner.clone().list().to_array(width).into())
    }

    fn list_drop_nulls(&self) -> Result<Self> {
        Ok(self.inner.clone().list().drop_nulls().into())
    }

    fn list_count_matches(&self, expr: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .list()
            .count_matches(expr.inner.clone())
            .into())
    }
}
