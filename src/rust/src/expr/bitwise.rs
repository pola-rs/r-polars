use crate::PlRExpr;
use savvy::{Result, savvy};

#[savvy]
impl PlRExpr {
    fn bitwise_count_ones(&self) -> Result<Self> {
        Ok(self.inner.clone().bitwise_count_ones().into())
    }

    fn bitwise_count_zeros(&self) -> Result<Self> {
        Ok(self.inner.clone().bitwise_count_zeros().into())
    }

    fn bitwise_leading_ones(&self) -> Result<Self> {
        Ok(self.inner.clone().bitwise_leading_ones().into())
    }

    fn bitwise_leading_zeros(&self) -> Result<Self> {
        Ok(self.inner.clone().bitwise_leading_zeros().into())
    }

    fn bitwise_trailing_ones(&self) -> Result<Self> {
        Ok(self.inner.clone().bitwise_trailing_ones().into())
    }

    fn bitwise_trailing_zeros(&self) -> Result<Self> {
        Ok(self.inner.clone().bitwise_trailing_zeros().into())
    }

    fn bitwise_and(&self) -> Result<Self> {
        Ok(self.inner.clone().bitwise_and().into())
    }

    fn bitwise_or(&self) -> Result<Self> {
        Ok(self.inner.clone().bitwise_or().into())
    }

    fn bitwise_xor(&self) -> Result<Self> {
        Ok(self.inner.clone().bitwise_xor().into())
    }
}
