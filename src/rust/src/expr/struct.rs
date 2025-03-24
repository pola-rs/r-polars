use crate::{PlRExpr, error::RPolarsErr, prelude::*};
use savvy::{ListSexp, NumericScalar, Result, StringSexp, savvy};

#[savvy]
impl PlRExpr {
    fn struct_field_by_index(&self, index: NumericScalar) -> Result<Self> {
        let index = <Wrap<i64>>::try_from(index)?.0;
        Ok(self.inner.clone().struct_().field_by_index(index).into())
    }

    fn struct_multiple_fields(&self, names: StringSexp) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .struct_()
            .field_by_names(names.iter())
            .into())
    }

    fn struct_rename_fields(&self, names: StringSexp) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .struct_()
            .rename_fields(names.iter())
            .into())
    }

    #[allow(unused_variables)]
    fn struct_json_encode(&self) -> Result<Self> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            Ok(self.inner.clone().struct_().json_encode().into())
        }
        #[cfg(target_arch = "wasm32")]
        {
            Err(RPolarsErr::Other(format!("Not supported in WASM")).into())
        }
    }

    fn struct_with_fields(&self, fields: ListSexp) -> Result<Self> {
        let fields = <Wrap<Vec<Expr>>>::from(fields).0;
        let e = self
            .inner
            .clone()
            .struct_()
            .with_fields(fields)
            .map_err(RPolarsErr::from)?;
        Ok(e.into())
    }
}
