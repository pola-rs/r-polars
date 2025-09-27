use crate::expr::selector::PlRSelector;
use crate::prelude::Wrap;
use crate::{PlRDataType, PlRExpr, RPolarsErr, prelude::*};
use polars::prelude::{DataTypeExpr, Schema};
use savvy::{ListSexp, NumericScalar, Result, savvy};

#[savvy]
#[repr(transparent)]
#[derive(Clone)]
pub struct PlRDataTypeExpr {
    pub inner: DataTypeExpr,
}

impl From<DataTypeExpr> for PlRDataTypeExpr {
    fn from(expr: DataTypeExpr) -> Self {
        PlRDataTypeExpr { inner: expr }
    }
}

#[savvy]
impl PlRDataTypeExpr {
    pub fn from_dtype(datatype: &PlRDataType) -> Result<Self> {
        Ok(DataTypeExpr::Literal(datatype.dt.clone()).into())
    }

    pub fn of_expr(expr: PlRExpr) -> Result<Self> {
        Ok(DataTypeExpr::OfExpr(Box::new(expr.inner)).into())
    }

    pub fn self_dtype() -> Result<Self> {
        Ok(DataTypeExpr::SelfDtype.into())
    }

    pub fn collect_dtype(&self, schema: ListSexp) -> Result<PlRDataType> {
        let schema = <Wrap<Schema>>::try_from(schema)?.0;
        self.clone()
            .inner
            .into_datatype(&schema)
            .map(Into::into)
            .map_err(RPolarsErr::from)
            .map_err(Into::into)
    }

    pub fn inner_dtype(&self) -> Result<Self> {
        Ok(self.inner.clone().inner_dtype().into())
    }

    pub fn equals(&self, other: &PlRDataTypeExpr) -> Result<PlRExpr> {
        Ok(self.inner.clone().equals(other.inner.clone()).into())
    }

    pub fn display(&self) -> Result<PlRExpr> {
        Ok(self.inner.clone().display().into())
    }

    pub fn matches(&self, selector: &PlRSelector) -> Result<PlRExpr> {
        let dtype_selector = DataTypeSelector::try_from(selector)?;
        Ok(self.inner.clone().matches(dtype_selector).into())
    }

    // TODO: support this
    // pub fn struct_with_fields(fields: Vec<(String, PlRDataTypeExpr)>) -> Result<Self> {
    //     let fields = fields
    //         .into_iter()
    //         .map(|(name, dt_expr)| (PlSmallStr::from_string(name), dt_expr.inner))
    //         .collect();
    //     DataTypeExpr::StructWithFields(fields).into()
    // }

    pub fn wrap_in_list(&self) -> Result<Self> {
        Ok(self.inner.clone().wrap_in_list().into())
    }

    pub fn wrap_in_array(&self, width: NumericScalar) -> Result<Self> {
        let width = <Wrap<usize>>::try_from(width)?.0;
        Ok(self.inner.clone().wrap_in_array(width).into())
    }

    pub fn to_unsigned_integer(&self) -> Result<Self> {
        Ok(self.inner.clone().int().to_unsigned().into())
    }

    pub fn to_signed_integer(&self) -> Result<Self> {
        Ok(self.inner.clone().int().to_signed().into())
    }

    pub fn default_value(
        &self,
        n: NumericScalar,
        numeric_to_one: bool,
        num_list_values: NumericScalar,
    ) -> Result<PlRExpr> {
        let n = <Wrap<usize>>::try_from(n)?.0;
        let num_list_values = <Wrap<usize>>::try_from(num_list_values)?.0;
        Ok(self
            .inner
            .clone()
            .default_value(n, numeric_to_one, num_list_values)
            .into())
    }

    pub fn list_inner_dtype(&self) -> Result<Self> {
        Ok(self.inner.clone().list().inner_dtype().into())
    }

    pub fn arr_inner_dtype(&self) -> Result<Self> {
        Ok(self.inner.clone().arr().inner_dtype().into())
    }

    pub fn arr_width(&self) -> Result<PlRExpr> {
        Ok(self.inner.clone().arr().width().into())
    }

    pub fn arr_shape(&self) -> Result<PlRExpr> {
        Ok(self.inner.clone().arr().shape().into())
    }

    pub fn struct_field_dtype_by_index(&self, index: NumericScalar) -> Result<Self> {
        let index = <Wrap<i64>>::try_from(index)?.0;
        Ok(self
            .inner
            .clone()
            .struct_()
            .field_dtype_by_index(index)
            .into())
    }

    pub fn struct_field_dtype_by_name(&self, name: &str) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .struct_()
            .field_dtype_by_name(name)
            .into())
    }

    pub fn struct_field_names(&self) -> Result<PlRExpr> {
        Ok(self.inner.clone().struct_().field_names().into())
    }
}
