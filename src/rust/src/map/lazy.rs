use crate::{
    PlRExpr,
    expr::datatype::PlRDataTypeExpr,
    prelude::*,
    r_threads::ThreadCom,
    r_udf::{CONFIG, RUdf, RUdfSignature},
};
use polars_plan::{
    dsl::udf::try_infer_udf_output_dtype,
    prelude::{
        AnonymousColumnsUdf, ColumnsUdf, DataTypeExpr, Expr, FunctionFlags, FunctionOptions,
        new_column_udf,
    },
};
use savvy::{FunctionSexp, Result};
use std::sync::{Arc, OnceLock};

struct RUdfExpression {
    lambda: RUdf,
    output_type: Option<DataTypeExpr>,
    materialized_field: OnceLock<Field>,
}

impl RUdfExpression {
    fn call_r(&self, columns: &[Column]) -> PolarsResult<Column> {
        let thread_com =
            ThreadCom::try_from_global(&CONFIG).map_err(|e| PolarsError::ComputeError(e.into()))?;
        thread_com.send(RUdfSignature::SeriesToSeries(
            self.lambda.clone(),
            columns[0].as_materialized_series().clone(),
        ));
        let s: Series = thread_com
            .recv()
            .try_into()
            .map_err(|e: String| PolarsError::ComputeError(e.into()))?;
        Ok(s.into_column())
    }
}

impl ColumnsUdf for RUdfExpression {
    fn call_udf(&self, columns: &mut [Column]) -> PolarsResult<Column> {
        let field = self
            .materialized_field
            .get()
            .expect("map_batches field should have been materialized");
        let mut output = self.call_r(columns)?;
        let must_cast = output
            .dtype()
            .matches_schema_type(field.dtype())
            .map_err(|_| {
                polars_err!(
                    SchemaMismatch: "expected output type '{:?}', got '{:?}'; set `return_dtype` to the proper datatype",
                    field.dtype(), output.dtype(),
                )
            })?;
        if must_cast {
            output = output.cast(field.dtype())?;
        }
        Ok(output)
    }
}

impl AnonymousColumnsUdf for RUdfExpression {
    fn as_column_udf(self: Arc<Self>) -> Arc<dyn ColumnsUdf> {
        self
    }

    fn deep_clone(self: Arc<Self>) -> Arc<dyn AnonymousColumnsUdf> {
        Arc::new(Self {
            lambda: self.lambda.clone(),
            output_type: self.output_type.clone(),
            materialized_field: OnceLock::new(),
        })
    }

    fn get_field(&self, input_schema: &Schema, fields: &[Field]) -> PolarsResult<Field> {
        let field = match self.materialized_field.get() {
            Some(field) => field.clone(),
            None => {
                let dtype = match self.output_type.as_ref() {
                    Some(output_type) => output_type
                        .clone()
                        .into_datatype_with_self(input_schema, fields[0].dtype())?,
                    None => try_infer_udf_output_dtype(&|columns| self.call_r(columns), fields)?,
                };
                let field = Field::new(fields[0].name().clone(), dtype);
                self.materialized_field.get_or_init(|| field.clone());
                field
            }
        };
        Ok(field)
    }
}

pub fn map_expr(
    rexpr: &PlRExpr,
    lambda: FunctionSexp,
    output_type: Option<&PlRDataTypeExpr>,
    is_elementwise: bool,
    returns_scalar: bool,
) -> Result<PlRExpr> {
    let function = RUdfExpression {
        lambda: RUdf::new(lambda),
        output_type: output_type.map(|t| t.inner.clone()),
        materialized_field: OnceLock::new(),
    };
    let mut flags = FunctionFlags::default() | FunctionFlags::OPTIONAL_RE_ENTRANT;
    if is_elementwise {
        flags.set_elementwise();
    }
    if returns_scalar {
        flags |= FunctionFlags::RETURNS_SCALAR;
    }

    Ok(Expr::AnonymousFunction {
        input: vec![rexpr.inner.clone()],
        function: new_column_udf(function),
        options: FunctionOptions {
            flags,
            ..Default::default()
        },
        fmt_str: Box::new("map_batches".into()),
    }
    .into())
}
