use crate::{PlRExpr, prelude::*};
use polars::prelude::*;
use savvy::{NumericScalar, NumericSexp, Result, savvy};

#[savvy]
impl PlRExpr {
    fn rolling_sum(
        &self,
        window_size: NumericScalar,
        center: bool,
        weights: Option<NumericSexp>,
        min_periods: Option<NumericScalar>,
    ) -> Result<Self> {
        let window_size = <Wrap<usize>>::try_from(window_size)?.0;
        let weights: Option<Vec<f64>> = weights.map(|x| x.as_slice_f64().into());
        let min_periods: usize = match min_periods {
            Some(x) => <Wrap<usize>>::try_from(x)?.0,
            None => window_size,
        };
        let options = RollingOptionsFixedWindow {
            window_size,
            weights,
            min_periods,
            center,
            ..Default::default()
        };
        Ok(self.inner.clone().rolling_sum(options).into())
    }

    fn rolling_sum_by(
        &self,
        by: &PlRExpr,
        window_size: &str,
        min_periods: NumericScalar,
        closed: &str,
    ) -> Result<Self> {
        let min_periods = <Wrap<usize>>::try_from(min_periods)?.0;
        let closed = <Wrap<ClosedWindow>>::try_from(closed)?.0;
        let options = RollingOptionsDynamicWindow {
            window_size: Duration::parse(window_size),
            min_periods,
            closed_window: closed,
            fn_params: None,
        };
        Ok(self
            .inner
            .clone()
            .rolling_sum_by(by.inner.clone(), options)
            .into())
    }

    fn rolling_min(
        &self,
        window_size: NumericScalar,
        center: bool,
        weights: Option<NumericSexp>,
        min_periods: Option<NumericScalar>,
    ) -> Result<Self> {
        let window_size = <Wrap<usize>>::try_from(window_size)?.0;
        let weights: Option<Vec<f64>> = weights.map(|x| x.as_slice_f64().into());
        let min_periods: usize = match min_periods {
            Some(x) => <Wrap<usize>>::try_from(x)?.0,
            None => window_size,
        };
        let options = RollingOptionsFixedWindow {
            window_size,
            weights,
            min_periods,
            center,
            ..Default::default()
        };
        Ok(self.inner.clone().rolling_min(options).into())
    }

    fn rolling_min_by(
        &self,
        by: &PlRExpr,
        window_size: &str,
        min_periods: NumericScalar,
        closed: &str,
    ) -> Result<Self> {
        let min_periods = <Wrap<usize>>::try_from(min_periods)?.0;
        let closed = <Wrap<ClosedWindow>>::try_from(closed)?.0;
        let options = RollingOptionsDynamicWindow {
            window_size: Duration::parse(window_size),
            min_periods,
            closed_window: closed,
            fn_params: None,
        };
        Ok(self
            .inner
            .clone()
            .rolling_min_by(by.inner.clone(), options)
            .into())
    }

    fn rolling_max(
        &self,
        window_size: NumericScalar,
        center: bool,
        weights: Option<NumericSexp>,
        min_periods: Option<NumericScalar>,
    ) -> Result<Self> {
        let window_size = <Wrap<usize>>::try_from(window_size)?.0;
        let weights: Option<Vec<f64>> = weights.map(|x| x.as_slice_f64().into());
        let min_periods: usize = match min_periods {
            Some(x) => <Wrap<usize>>::try_from(x)?.0,
            None => window_size,
        };
        let options = RollingOptionsFixedWindow {
            window_size,
            weights,
            min_periods,
            center,
            ..Default::default()
        };
        Ok(self.inner.clone().rolling_max(options).into())
    }

    fn rolling_max_by(
        &self,
        by: &PlRExpr,
        window_size: &str,
        min_periods: NumericScalar,
        closed: &str,
    ) -> Result<Self> {
        let min_periods = <Wrap<usize>>::try_from(min_periods)?.0;
        let closed = <Wrap<ClosedWindow>>::try_from(closed)?.0;
        let options = RollingOptionsDynamicWindow {
            window_size: Duration::parse(window_size),
            min_periods,
            closed_window: closed,
            fn_params: None,
        };
        Ok(self
            .inner
            .clone()
            .rolling_max_by(by.inner.clone(), options)
            .into())
    }

    fn rolling_mean(
        &self,
        window_size: NumericScalar,
        center: bool,
        weights: Option<NumericSexp>,
        min_periods: Option<NumericScalar>,
    ) -> Result<Self> {
        let window_size = <Wrap<usize>>::try_from(window_size)?.0;
        let weights: Option<Vec<f64>> = weights.map(|x| x.as_slice_f64().into());
        let min_periods: usize = match min_periods {
            Some(x) => <Wrap<usize>>::try_from(x)?.0,
            None => window_size,
        };
        let options = RollingOptionsFixedWindow {
            window_size,
            weights,
            min_periods,
            center,
            ..Default::default()
        };

        Ok(self.inner.clone().rolling_mean(options).into())
    }

    fn rolling_mean_by(
        &self,
        by: &PlRExpr,
        window_size: &str,
        min_periods: NumericScalar,
        closed: &str,
    ) -> Result<Self> {
        let min_periods = <Wrap<usize>>::try_from(min_periods)?.0;
        let closed = <Wrap<ClosedWindow>>::try_from(closed)?.0;
        let options = RollingOptionsDynamicWindow {
            window_size: Duration::parse(window_size),
            min_periods,
            closed_window: closed,
            fn_params: None,
        };

        Ok(self
            .inner
            .clone()
            .rolling_mean_by(by.inner.clone(), options)
            .into())
    }

    fn rolling_std(
        &self,
        window_size: NumericScalar,
        center: bool,
        ddof: NumericScalar,
        weights: Option<NumericSexp>,
        min_periods: Option<NumericScalar>,
    ) -> Result<Self> {
        let ddof = <Wrap<u8>>::try_from(ddof)?.0;
        let window_size = <Wrap<usize>>::try_from(window_size)?.0;
        let weights: Option<Vec<f64>> = weights.map(|x| x.as_slice_f64().into());
        let min_periods: usize = match min_periods {
            Some(x) => <Wrap<usize>>::try_from(x)?.0,
            None => window_size,
        };
        let options = RollingOptionsFixedWindow {
            window_size,
            weights,
            min_periods,
            center,
            fn_params: Some(RollingFnParams::Var(RollingVarParams { ddof })),
        };

        Ok(self.inner.clone().rolling_std(options).into())
    }

    fn rolling_std_by(
        &self,
        by: &PlRExpr,
        window_size: &str,
        min_periods: NumericScalar,
        closed: &str,
        ddof: NumericScalar,
    ) -> Result<Self> {
        let min_periods = <Wrap<usize>>::try_from(min_periods)?.0;
        let ddof = <Wrap<u8>>::try_from(ddof)?.0;
        let closed = <Wrap<ClosedWindow>>::try_from(closed)?.0;
        let options = RollingOptionsDynamicWindow {
            window_size: Duration::parse(window_size),
            min_periods,
            closed_window: closed,
            fn_params: Some(RollingFnParams::Var(RollingVarParams { ddof })),
        };

        Ok(self
            .inner
            .clone()
            .rolling_std_by(by.inner.clone(), options)
            .into())
    }

    fn rolling_var(
        &self,
        window_size: NumericScalar,
        center: bool,
        ddof: NumericScalar,
        weights: Option<NumericSexp>,
        min_periods: Option<NumericScalar>,
    ) -> Result<Self> {
        let ddof = <Wrap<u8>>::try_from(ddof)?.0;
        let window_size = <Wrap<usize>>::try_from(window_size)?.0;
        let weights: Option<Vec<f64>> = weights.map(|x| x.as_slice_f64().into());
        let min_periods: usize = match min_periods {
            Some(x) => <Wrap<usize>>::try_from(x)?.0,
            None => window_size,
        };
        let options = RollingOptionsFixedWindow {
            window_size,
            weights,
            min_periods,
            center,
            fn_params: Some(RollingFnParams::Var(RollingVarParams { ddof })),
        };

        Ok(self.inner.clone().rolling_var(options).into())
    }

    fn rolling_var_by(
        &self,
        by: &PlRExpr,
        window_size: &str,
        min_periods: NumericScalar,
        closed: &str,
        ddof: NumericScalar,
    ) -> Result<Self> {
        let min_periods = <Wrap<usize>>::try_from(min_periods)?.0;
        let ddof = <Wrap<u8>>::try_from(ddof)?.0;
        let closed = <Wrap<ClosedWindow>>::try_from(closed)?.0;
        let options = RollingOptionsDynamicWindow {
            window_size: Duration::parse(window_size),
            min_periods,
            closed_window: closed,
            fn_params: Some(RollingFnParams::Var(RollingVarParams { ddof })),
        };

        Ok(self
            .inner
            .clone()
            .rolling_var_by(by.inner.clone(), options)
            .into())
    }

    fn rolling_median(
        &self,
        window_size: NumericScalar,
        center: bool,
        weights: Option<NumericSexp>,
        min_periods: Option<NumericScalar>,
    ) -> Result<Self> {
        let window_size = <Wrap<usize>>::try_from(window_size)?.0;
        let weights: Option<Vec<f64>> = weights.map(|x| x.as_slice_f64().into());
        let min_periods: usize = match min_periods {
            Some(x) => <Wrap<usize>>::try_from(x)?.0,
            None => window_size,
        };
        let options = RollingOptionsFixedWindow {
            window_size,
            min_periods,
            weights,
            center,
            fn_params: None,
        };
        Ok(self.inner.clone().rolling_median(options).into())
    }

    fn rolling_median_by(
        &self,
        by: &PlRExpr,
        window_size: &str,
        min_periods: NumericScalar,
        closed: &str,
    ) -> Result<Self> {
        let min_periods = <Wrap<usize>>::try_from(min_periods)?.0;
        let closed = <Wrap<ClosedWindow>>::try_from(closed)?.0;
        let options = RollingOptionsDynamicWindow {
            window_size: Duration::parse(window_size),
            min_periods,
            closed_window: closed,
            fn_params: None,
        };
        Ok(self
            .inner
            .clone()
            .rolling_median_by(by.inner.clone(), options)
            .into())
    }

    fn rolling_quantile(
        &self,
        quantile: f64,
        interpolation: &str,
        window_size: NumericScalar,
        center: bool,
        weights: Option<NumericSexp>,
        min_periods: Option<NumericScalar>,
    ) -> Result<Self> {
        let window_size = <Wrap<usize>>::try_from(window_size)?.0;
        let weights: Option<Vec<f64>> = weights.map(|x| x.as_slice_f64().into());
        let interpolation = <Wrap<QuantileMethod>>::try_from(interpolation)?.0;
        let min_periods: usize = match min_periods {
            Some(x) => <Wrap<usize>>::try_from(x)?.0,
            None => window_size,
        };
        let options = RollingOptionsFixedWindow {
            window_size,
            weights,
            min_periods,
            center,
            fn_params: None,
        };

        Ok(self
            .inner
            .clone()
            .rolling_quantile(interpolation, quantile, options)
            .into())
    }

    fn rolling_quantile_by(
        &self,
        by: &PlRExpr,
        quantile: f64,
        interpolation: &str,
        window_size: &str,
        min_periods: NumericScalar,
        closed: &str,
    ) -> Result<Self> {
        let min_periods = <Wrap<usize>>::try_from(min_periods)?.0;
        let interpolation = <Wrap<QuantileMethod>>::try_from(interpolation)?.0;
        let closed = <Wrap<ClosedWindow>>::try_from(closed)?.0;
        let options = RollingOptionsDynamicWindow {
            window_size: Duration::parse(window_size),
            min_periods,
            closed_window: closed,
            fn_params: None,
        };

        Ok(self
            .inner
            .clone()
            .rolling_quantile_by(by.inner.clone(), interpolation, quantile, options)
            .into())
    }

    fn rolling_skew(
        &self,
        window_size: NumericScalar,
        bias: bool,
        center: bool,
        min_samples: Option<NumericScalar>,
    ) -> Result<Self> {
        let window_size = <Wrap<usize>>::try_from(window_size)?.0;
        let min_periods: usize = match min_samples {
            Some(x) => <Wrap<usize>>::try_from(x)?.0,
            None => window_size,
        };
        let options = RollingOptionsFixedWindow {
            window_size,
            weights: None,
            min_periods,
            center,
            fn_params: Some(RollingFnParams::Skew { bias }),
        };
        Ok(self.inner.clone().rolling_skew(options).into())
    }

    // fn rolling_map(
    //     &self,
    //     lambda: PyObject,
    //     window_size: NumericScalar,
    //     weights: Option<NumericSexp>,
    //     min_periods: Option<NumericScalar>,
    //     center: bool,
    // ) -> Result<Self> {
    //     let min_periods: usize = match min_periods {
    //       Some(x) => <Wrap<usize>>::try_from(x)?.0,
    //       None => window_size
    //     };
    //     let options = RollingOptionsFixedWindow {
    //         window_size,
    //         weights,
    //         min_periods,
    //         center,
    //         ..Default::default()
    //     };
    //     let function = move |s: &Series| {
    //         Python::with_gil(|py| {
    //             let out = call_lambda_with_series(py, s.clone(), &lambda)
    //                 .expect("python function failed");
    //             match out.getattr(py, "_s") {
    //                 Ok(pyseries) => {
    //                     let pyseries = pyseries.extract::<PySeries>(py).unwrap();
    //                     pyseries.series
    //                 }
    //                 Err(_) => {
    //                     let obj = out;
    //                     let is_float = obj.bind(py).is_instance_of::<PyFloat>();

    //                     let dtype = s.dtype();

    //                     use DataType::*;
    //                     let result = match dtype {
    //                         UInt8 => {
    //                             if is_float {
    //                                 let v = obj.extract::<f64>(py).unwrap();
    //                                 Ok(UInt8Chunked::from_slice(PlSmallStr::EMPTY, &[v as u8])
    //                                     .into_series())
    //                             } else {
    //                                 obj.extract::<u8>(py).map(|v| {
    //                                     UInt8Chunked::from_slice(PlSmallStr::EMPTY, &[v])
    //                                         .into_series()
    //                                 })
    //                             }
    //                         }
    //                         UInt16 => {
    //                             if is_float {
    //                                 let v = obj.extract::<f64>(py).unwrap();
    //                                 Ok(UInt16Chunked::from_slice(PlSmallStr::EMPTY, &[v as u16])
    //                                     .into_series())
    //                             } else {
    //                                 obj.extract::<u16>(py).map(|v| {
    //                                     UInt16Chunked::from_slice(PlSmallStr::EMPTY, &[v])
    //                                         .into_series()
    //                                 })
    //                             }
    //                         }
    //                         UInt32 => {
    //                             if is_float {
    //                                 let v = obj.extract::<f64>(py).unwrap();
    //                                 Ok(UInt32Chunked::from_slice(PlSmallStr::EMPTY, &[v as u32])
    //                                     .into_series())
    //                             } else {
    //                                 obj.extract::<u32>(py).map(|v| {
    //                                     UInt32Chunked::from_slice(PlSmallStr::EMPTY, &[v])
    //                                         .into_series()
    //                                 })
    //                             }
    //                         }
    //                         UInt64 => {
    //                             if is_float {
    //                                 let v = obj.extract::<f64>(py).unwrap();
    //                                 Ok(UInt64Chunked::from_slice(PlSmallStr::EMPTY, &[v as u64])
    //                                     .into_series())
    //                             } else {
    //                                 obj.extract::<u64>(py).map(|v| {
    //                                     UInt64Chunked::from_slice(PlSmallStr::EMPTY, &[v])
    //                                         .into_series()
    //                                 })
    //                             }
    //                         }
    //                         Int8 => {
    //                             if is_float {
    //                                 let v = obj.extract::<f64>(py).unwrap();
    //                                 Ok(Int8Chunked::from_slice(PlSmallStr::EMPTY, &[v as i8])
    //                                     .into_series())
    //                             } else {
    //                                 obj.extract::<i8>(py).map(|v| {
    //                                     Int8Chunked::from_slice(PlSmallStr::EMPTY, &[v])
    //                                         .into_series()
    //                                 })
    //                             }
    //                         }
    //                         Int16 => {
    //                             if is_float {
    //                                 let v = obj.extract::<f64>(py).unwrap();
    //                                 Ok(Int16Chunked::from_slice(PlSmallStr::EMPTY, &[v as i16])
    //                                     .into_series())
    //                             } else {
    //                                 obj.extract::<i16>(py).map(|v| {
    //                                     Int16Chunked::from_slice(PlSmallStr::EMPTY, &[v])
    //                                         .into_series()
    //                                 })
    //                             }
    //                         }
    //                         Int32 => {
    //                             if is_float {
    //                                 let v = obj.extract::<f64>(py).unwrap();
    //                                 Ok(Int32Chunked::from_slice(PlSmallStr::EMPTY, &[v as i32])
    //                                     .into_series())
    //                             } else {
    //                                 obj.extract::<i32>(py).map(|v| {
    //                                     Int32Chunked::from_slice(PlSmallStr::EMPTY, &[v])
    //                                         .into_series()
    //                                 })
    //                             }
    //                         }
    //                         Int64 => {
    //                             if is_float {
    //                                 let v = obj.extract::<f64>(py).unwrap();
    //                                 Ok(Int64Chunked::from_slice(PlSmallStr::EMPTY, &[v as i64])
    //                                     .into_series())
    //                             } else {
    //                                 obj.extract::<i64>(py).map(|v| {
    //                                     Int64Chunked::from_slice(PlSmallStr::EMPTY, &[v])
    //                                         .into_series()
    //                                 })
    //                             }
    //                         }
    //                         Float32 => obj.extract::<f32>(py).map(|v| {
    //                             Float32Chunked::from_slice(PlSmallStr::EMPTY, &[v]).into_series()
    //                         }),
    //                         Float64 => obj.extract::<f64>(py).map(|v| {
    //                             Float64Chunked::from_slice(PlSmallStr::EMPTY, &[v]).into_series()
    //                         }),
    //                         dt => panic!("{dt:?} not implemented"),
    //                     };

    //                     match result {
    //                         Ok(s) => s,
    //                         Err(e) => {
    //                             panic!("{e:?}")
    //                         }
    //                     }
    //                 }
    //             }
    //         })
    //     };
    //     self.inner
    //         .clone()
    //         .rolling_map(Arc::new(function), GetOutput::same_type(), options)
    //         .with_fmt("rolling_map")
    //         .into()
    // }
}
