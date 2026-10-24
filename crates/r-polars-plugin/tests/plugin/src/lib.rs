use pyo3_polars::derive::polars_expr;
use pyo3_polars::export::polars_core::prelude::*;

#[polars_expr(output_type = Int64)]
fn double(inputs: &[Series]) -> PolarsResult<Series> {
    Ok((inputs[0].i64()? * 2).into_series())
}
