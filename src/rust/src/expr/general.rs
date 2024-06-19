use crate::datatypes::PlRDataType;
use crate::PlRExpr;
use polars::lazy::dsl;
use polars::prelude::*;
use polars::series::ops::NullBehavior;
use polars_core::series::IsSorted;
use polars_core::utils::arrow::compute::cast::CastOptions;
use savvy::{r_println, savvy};
use std::io::Cursor;
use std::ops::Neg;

#[savvy]
impl PlRExpr {
    fn print(&self) -> savvy::Result<()> {
        r_println!("{:?}", self.inner);
        Ok(())
    }

    fn add(&self, rhs: PlRExpr) -> savvy::Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::Plus, rhs.inner).into())
    }

    fn sub(&self, rhs: PlRExpr) -> savvy::Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::Minus, rhs.inner).into())
    }

    fn mul(&self, rhs: PlRExpr) -> savvy::Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::Multiply, rhs.inner).into())
    }

    fn div(&self, rhs: PlRExpr) -> savvy::Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::TrueDivide, rhs.inner).into())
    }

    fn rem(&self, rhs: PlRExpr) -> savvy::Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::Modulus, rhs.inner).into())
    }

    fn floor_div(&self, rhs: PlRExpr) -> savvy::Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::FloorDivide, rhs.inner).into())
    }

    fn neg(&self) -> savvy::Result<Self> {
        Ok(self.inner.clone().neg().into())
    }

    fn cast(&self, data_type: PlRDataType, strict: bool) -> savvy::Result<Self> {
        let dt = data_type.dt;

        let expr = if strict {
            self.inner.clone().strict_cast(dt)
        } else {
            self.inner.clone().cast(dt)
        };

        Ok(expr.into())
    }
}
