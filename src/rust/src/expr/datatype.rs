use polars::prelude::{DataType, DataTypeExpr, PlSmallStr, Schema};
use savvy::{Result, savvy};

use crate::prelude::Wrap;
use crate::{PlRDataType, PlRExpr, RPolarsErr, prelude::*};

#[savvy]
#[repr(transparent)]
#[derive(Clone)]
pub struct PlRDataTypeExpr {
    pub inner: DataTypeExpr,
}

impl From<DataTypeExpr> for PlRDataTypeExpr {
    fn from(expr: DataTypeExpr) -> Result<Self> {
        PlRDataTypeExpr { inner: expr }
    }
}

#[savvy]
impl PlRDataTypeExpr {
    pub fn from_dtype(datatype: Wrap<PlRDataType>) -> Result<Self> {
        DataTypeExpr::Literal(datatype.0).into()
    }

    pub fn of_expr(expr: PlRExpr) -> Result<Self> {
        Ok(DataTypeExpr::OfExpr(Box::new(expr.inner)).into())
    }

    pub fn self_dtype() -> Result<Self> {
        Ok(DataTypeExpr::SelfDtype.into())
    }

    // pub fn collect_dtype<'py>(
    //     &self,
    //     schema: Wrap<Schema>,
    // ) -> Result<Sexp> {
    //     let dtype = self
    //         .clone()
    //         .inner
    //         .into_datatype(&schema.0.clone())
    //         .map_err(RPolarsErr::from)?;
    //     Wrap(dtype).into_pyobject(py)
    // }

    // fn collect_schema(&mut self) -> Result<Sexp> {
    //     let schema = self.ldf.collect_schema().map_err(RPolarsErr::from)?;
    //     let mut out = OwnedListSexp::new(schema.len(), true)?;
    //     for (i, (name, dtype)) in schema.iter().enumerate() {
    //         let value: Sexp = PlRDataType::from(dtype.clone()).try_into()?;
    //         let _ = out.set_name_and_value(i, name.as_str(), value);
    //     }
    //     Ok(out.into())
    // }

    pub fn inner_dtype(&self) -> Result<Self> {
        Ok(self.inner.clone().inner_dtype().into())
    }

    pub fn equals(&self, other: &Self) -> Result<PlRExpr> {
        Ok(self.inner.clone().equals(other.inner.clone()).into())
    }

    pub fn display(&self) -> Result<PlRExpr> {
        Ok(self.inner.clone().display().into())
    }

    pub fn matches(&self, selector: PySelector) -> Result<PlRExpr> {
        let dtype_selector = parse_datatype_selector(selector)?;
        Ok(self.inner.clone().matches(dtype_selector).into())
    }

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

    pub fn wrap_in_array(&self, width: usize) -> Result<Self> {
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
        n: usize,
        numeric_to_one: bool,
        num_list_values: usize,
    ) -> Result<PlRExpr> {
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

    pub fn struct_field_dtype_by_index(&self, index: i64) -> Result<Self> {
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
