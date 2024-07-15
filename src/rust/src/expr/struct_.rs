use crate::{prelude::*, PlRExpr};
use savvy::{savvy, ListSexp, NumericScalar, Result, StringSexp};

#[savvy]
impl PlRExpr {
    fn struct_field_by_index(&self, index: NumericScalar) -> Result<Self> {
        let index = index.as_i32()?;
        Ok(self
            .inner
            .clone()
            .struct_()
            .field_by_index(index as i64)
            .into())
    }

    fn struct_field_by_name(&self, name: &str) -> Result<Self> {
        Ok(self.inner.clone().struct_().field_by_name(name).into())
    }

    fn struct_multiple_fields(&self, names: StringSexp) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .struct_()
            .field_by_names(&names.to_vec())
            .into())
    }

    fn struct_rename_fields(&self, names: StringSexp) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .struct_()
            .rename_fields(names.iter().map(|s| s.to_string()).collect())
            .into())
    }

    fn struct_json_encode(&self) -> Result<Self> {
        Ok(self.inner.clone().struct_().json_encode().into())
    }

    fn struct_with_fields(&self, fields: ListSexp) -> Result<Self> {
        let fields = <Wrap<Vec<Expr>>>::from(fields).0;
        Ok(self.inner.clone().struct_().with_fields(fields).into())
    }
}
