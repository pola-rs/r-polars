use pyo3_polars::derive::polars_expr;
use pyo3_polars::export::polars_core::prelude::*;

#[derive(serde::Deserialize)]
struct AddKwargs {
    offset: i64,
    enabled: bool,
}

#[polars_expr(output_type = Int64)]
fn add_offset(inputs: &[Series], kwargs: AddKwargs) -> PolarsResult<Series> {
    if kwargs.enabled {
        Ok((inputs[0].i64()? + kwargs.offset).into_series())
    } else {
        Ok(inputs[0].clone())
    }
}
