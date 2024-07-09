use crate::{prelude::*, PlRDataType, PlRExpr};
use polars::lazy::dsl;
use savvy::{r_println, savvy, ListSexp, LogicalSexp, NumericSexp, Result};
use std::ops::Neg;

#[savvy]
impl PlRExpr {
    fn print(&self) -> Result<()> {
        r_println!("{:?}", self.inner);
        Ok(())
    }

    fn add(&self, rhs: PlRExpr) -> Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::Plus, rhs.inner).into())
    }

    fn sub(&self, rhs: PlRExpr) -> Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::Minus, rhs.inner).into())
    }

    fn mul(&self, rhs: PlRExpr) -> Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::Multiply, rhs.inner).into())
    }

    fn div(&self, rhs: PlRExpr) -> Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::TrueDivide, rhs.inner).into())
    }

    fn rem(&self, rhs: PlRExpr) -> Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::Modulus, rhs.inner).into())
    }

    fn floor_div(&self, rhs: PlRExpr) -> Result<Self> {
        Ok(dsl::binary_expr(self.inner.clone(), Operator::FloorDivide, rhs.inner).into())
    }

    fn neg(&self) -> Result<Self> {
        Ok(self.inner.clone().neg().into())
    }

    fn eq(&self, other: PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().eq(other.inner).into())
    }

    fn eq_missing(&self, other: PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().eq_missing(other.inner).into())
    }

    fn neq(&self, other: PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().neq(other.inner).into())
    }

    fn neq_missing(&self, other: PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().neq_missing(other.inner).into())
    }

    fn gt(&self, other: PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().gt(other.inner).into())
    }

    fn gt_eq(&self, other: PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().gt_eq(other.inner).into())
    }

    fn lt_eq(&self, other: PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().lt_eq(other.inner).into())
    }

    fn lt(&self, other: PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().lt(other.inner).into())
    }

    fn alias(&self, name: &str) -> Result<Self> {
        Ok(self.inner.clone().alias(name).into())
    }

    fn not(&self) -> Result<Self> {
        Ok(self.inner.clone().not().into())
    }

    fn is_null(&self) -> Result<Self> {
        Ok(self.inner.clone().is_null().into())
    }

    fn is_not_null(&self) -> Result<Self> {
        Ok(self.inner.clone().is_not_null().into())
    }

    fn is_infinite(&self) -> Result<Self> {
        Ok(self.inner.clone().is_infinite().into())
    }

    fn is_finite(&self) -> Result<Self> {
        Ok(self.inner.clone().is_finite().into())
    }

    fn is_nan(&self) -> Result<Self> {
        Ok(self.inner.clone().is_nan().into())
    }

    fn is_not_nan(&self) -> Result<Self> {
        Ok(self.inner.clone().is_not_nan().into())
    }

    fn min(&self) -> Result<Self> {
        Ok(self.inner.clone().min().into())
    }

    fn max(&self) -> Result<Self> {
        Ok(self.inner.clone().max().into())
    }

    fn nan_max(&self) -> Result<Self> {
        Ok(self.inner.clone().nan_max().into())
    }

    fn nan_min(&self) -> Result<Self> {
        Ok(self.inner.clone().nan_min().into())
    }

    fn mean(&self) -> Result<Self> {
        Ok(self.inner.clone().mean().into())
    }

    fn median(&self) -> Result<Self> {
        Ok(self.inner.clone().median().into())
    }

    fn sum(&self) -> Result<Self> {
        Ok(self.inner.clone().sum().into())
    }

    fn cast(&self, data_type: PlRDataType, strict: bool) -> Result<Self> {
        let dt = data_type.dt;

        let expr = if strict {
            self.inner.clone().strict_cast(dt)
        } else {
            self.inner.clone().cast(dt)
        };

        Ok(expr.into())
    }

    fn sort_by(
        &self,
        by: ListSexp,
        descending: LogicalSexp,
        nulls_last: LogicalSexp,
        multithreaded: bool,
        maintain_order: bool,
    ) -> Result<Self> {
        let by = <Wrap<Vec<Expr>>>::from(by).0;
        Ok(self
            .inner
            .clone()
            .sort_by(
                by,
                SortMultipleOptions {
                    descending: descending.to_vec(),
                    nulls_last: nulls_last.to_vec(),
                    multithreaded,
                    maintain_order,
                },
            )
            .into())
    }

    fn first(&self) -> Result<Self> {
        Ok(self.inner.clone().first().into())
    }

    fn last(&self) -> Result<Self> {
        Ok(self.inner.clone().last().into())
    }

    fn reverse(&self) -> Result<Self> {
        Ok(self.inner.clone().reverse().into())
    }

    fn over(
        &self,
        partition_by: ListSexp,
        order_by_descending: bool,
        order_by_nulls_last: bool,
        mapping_strategy: &str,
        order_by: Option<ListSexp>,
    ) -> Result<Self> {
        let partition_by = <Wrap<Vec<Expr>>>::from(partition_by).0;
        let order_by = order_by.map(|order_by| {
            (
                <Wrap<Vec<Expr>>>::from(order_by).0,
                SortOptions {
                    descending: order_by_descending,
                    nulls_last: order_by_nulls_last,
                    maintain_order: false,
                    ..Default::default()
                },
            )
        });
        let mapping_strategy = <Wrap<WindowMapping>>::try_from(mapping_strategy)?.0;

        Ok(self
            .inner
            .clone()
            .over_with_options(partition_by, order_by, mapping_strategy)
            .into())
    }

    fn and(&self, other: PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().and(other.inner).into())
    }

    fn or(&self, other: PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().or(other.inner).into())
    }

    fn xor(&self, other: PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().xor(other.inner).into())
    }

    fn reshape(&self, dimensions: NumericSexp) -> Result<Self> {
        let dimensions: Vec<i64> = <Wrap<Vec<i64>>>::try_from(dimensions)?.0;
        Ok(self
            .inner
            .clone()
            .reshape(&dimensions, NestedType::Array)
            .into())
    }

    fn any(&self, ignore_nulls: bool) -> Result<Self> {
        Ok(self.inner.clone().any(ignore_nulls).into())
    }

    fn all(&self, ignore_nulls: bool) -> Result<Self> {
        Ok(self.inner.clone().all(ignore_nulls).into())
    }
}
