use crate::{
    PlRDataType, PlRExpr,
    prelude::*,
    r_threads::ThreadCom,
    r_udf::{CONFIG, RUdf, RUdfSignature},
};
use savvy::{FunctionSexp, Result};

pub fn map_single(
    rexpr: &PlRExpr,
    lambda: FunctionSexp,
    output_type: Option<&PlRDataType>,
    agg_list: bool,
    // TODO: support these options
    // is_elementwise: bool,
    // returns_scalar: bool,
) -> Result<PlRExpr> {
    let output_type = output_type.map(|t| t.dt.clone());
    let lambda = RUdf::new(lambda);
    let func = move |col: Column| {
        let thread_com = ThreadCom::try_from_global(&CONFIG)
            .expect("polars was thread could not initiate ThreadCommunication to R");
        thread_com.send(RUdfSignature::SeriesToSeries(
            lambda.clone(),
            col.as_materialized_series().clone(),
        ));
        let s: Series = thread_com.recv().try_into().unwrap();
        Ok(Some(s.into_column()))
    };

    let output_map = GetOutput::map_field(move |field| match &output_type {
        Some(dt) => Ok(Field::new(field.name().clone(), dt.clone())),
        None => Ok(field.clone()),
    });

    if agg_list {
        Ok(rexpr.inner.clone().map_list(func, output_map).into())
    } else {
        Ok(rexpr.inner.clone().map(func, output_map).into())
    }
}
