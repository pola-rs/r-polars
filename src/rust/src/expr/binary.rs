use crate::{PlRExpr, expr::datatype::PlRDataTypeExpr};
use savvy::{Result, savvy};

#[savvy]
impl PlRExpr {
    fn bin_contains(&self, literal: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .binary()
            .contains_literal(literal.inner.clone())
            .into())
    }

    fn bin_ends_with(&self, suffix: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .binary()
            .ends_with(suffix.inner.clone())
            .into())
    }

    fn bin_starts_with(&self, prefix: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .binary()
            .starts_with(prefix.inner.clone())
            .into())
    }

    fn bin_hex_decode(&self, strict: bool) -> Result<Self> {
        Ok(self.inner.clone().binary().hex_decode(strict).into())
    }

    fn bin_base64_decode(&self, strict: bool) -> Result<Self> {
        Ok(self.inner.clone().binary().base64_decode(strict).into())
    }

    fn bin_hex_encode(&self) -> Result<Self> {
        Ok(self.inner.clone().binary().hex_encode().into())
    }

    fn bin_base64_encode(&self) -> Result<Self> {
        Ok(self.inner.clone().binary().base64_encode().into())
    }

    fn bin_size_bytes(&self) -> Result<Self> {
        Ok(self.inner.clone().binary().size_bytes().into())
    }

    fn bin_reinterpret(&self, dtype: &PlRDataTypeExpr, kind: &str) -> Result<Self> {
        let is_little_endian = match kind {
            "little" => true,
            "big" => false,
            _ => unreachable!(),
        };
        Ok(self
            .inner
            .clone()
            .binary()
            .reinterpret(dtype.inner.clone(), is_little_endian)
            .into())
    }

    fn bin_get(&self, index: &PlRExpr, null_on_oob: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .binary()
            .get(index.inner.clone(), null_on_oob)
            .into())
    }
}
