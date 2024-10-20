use crate::{prelude::*, PlRExpr};
use savvy::{savvy, NumericScalar, Result};

#[savvy]
impl PlRExpr {
    fn arr_max(&self) -> Result<Self> {
        Ok(self.inner.clone().arr().max().into())
    }

    fn arr_min(&self) -> Result<Self> {
        Ok(self.inner.clone().arr().min().into())
    }

    fn arr_sum(&self) -> Result<Self> {
        Ok(self.inner.clone().arr().sum().into())
    }

    fn arr_std(&self, ddof: NumericScalar) -> Result<Self> {
        let ddof = <Wrap<u8>>::try_from(ddof)?.0;
        Ok(self.inner.clone().arr().std(ddof).into())
    }

    fn arr_var(&self, ddof: NumericScalar) -> Result<Self> {
        let ddof = <Wrap<u8>>::try_from(ddof)?.0;
        Ok(self.inner.clone().arr().var(ddof).into())
    }

    fn arr_median(&self) -> Result<Self> {
        Ok(self.inner.clone().arr().median().into())
    }

    fn arr_unique(&self, maintain_order: bool) -> Result<Self> {
        if maintain_order {
            Ok(self.inner.clone().arr().unique_stable().into())
        } else {
            Ok(self.inner.clone().arr().unique().into())
        }
    }

    fn arr_to_list(&self) -> Result<Self> {
        Ok(self.inner.clone().arr().to_list().into())
    }

    fn arr_all(&self) -> Result<Self> {
        Ok(self.inner.clone().arr().all().into())
    }

    fn arr_any(&self) -> Result<Self> {
        Ok(self.inner.clone().arr().any().into())
    }

    fn arr_sort(&self, descending: bool, nulls_last: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .arr()
            .sort(SortOptions {
                descending,
                nulls_last,
                ..Default::default()
            })
            .into())
    }

    fn arr_reverse(&self) -> Result<Self> {
        Ok(self.inner.clone().arr().reverse().into())
    }

    fn arr_arg_min(&self) -> Result<Self> {
        Ok(self.inner.clone().arr().arg_min().into())
    }

    fn arr_arg_max(&self) -> Result<Self> {
        Ok(self.inner.clone().arr().arg_max().into())
    }

    fn arr_get(&self, index: &PlRExpr, null_on_oob: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .arr()
            .get(index.inner.clone(), null_on_oob)
            .into())
    }

    fn arr_join(&self, separator: &PlRExpr, ignore_nulls: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .arr()
            .join(separator.inner.clone(), ignore_nulls)
            .into())
    }

    fn arr_contains(&self, other: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .arr()
            .contains(other.inner.clone())
            .into())
    }

    fn arr_count_matches(&self, expr: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .arr()
            .count_matches(expr.inner.clone())
            .into())
    }

    // fn arr_to_struct(&self, fields: Robj) -> Result<Self> {
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
    //     Ok(Ok(RPolarsExpr(self.inner.clone().arr().to_struct(fields))))
    // }

    fn arr_shift(&self, n: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().arr().shift(n.inner.clone()).into())
    }

    fn arr_n_unique(&self) -> Result<Self> {
        Ok(self.inner.clone().arr().n_unique().into())
    }
}
