use crate::{PlRExpr, prelude::*};
use savvy::{FunctionSexp, NumericScalar, Result, savvy};

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

    fn arr_contains(&self, other: &PlRExpr, nulls_equal: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .arr()
            .contains(other.inner.clone(), nulls_equal)
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

    fn arr_to_struct(&self, name_gen: Option<FunctionSexp>) -> Result<Self> {
        use crate::{
            RPolarsErr,
            r_threads::ThreadCom,
            r_udf::{CONFIG, RUdf, RUdfSignature},
        };
        use polars::prelude::array::ArrToStructNameGenerator;

        #[cfg(not(target_arch = "wasm32"))]
        let name_gen = name_gen.map(|lambda| {
            let lambda = RUdf::new(lambda);
            Arc::new(move |idx: usize| {
                let thread_com = ThreadCom::try_from_global(&CONFIG).unwrap();
                thread_com.send(RUdfSignature::Int32ToString(lambda.clone(), idx as i32));
                let res: PlSmallStr = thread_com.recv().try_into().unwrap();
                res
            }) as ArrToStructNameGenerator
        });
        #[cfg(target_arch = "wasm32")]
        let name_gen = match name_gen {
            Some(_) => {
                return Err(RPolarsErr::Other(
                    "Specifying a function name generator is not supported in WASM".to_string(),
                )
                .into());
            }
            None => None,
        };

        Ok(self
            .inner
            .clone()
            .arr()
            .to_struct(name_gen)
            .map_err(RPolarsErr::from)?
            .into())
    }

    fn arr_shift(&self, n: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().arr().shift(n.inner.clone()).into())
    }

    fn arr_n_unique(&self) -> Result<Self> {
        Ok(self.inner.clone().arr().n_unique().into())
    }
}
