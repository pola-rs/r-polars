# `Expr_sum`

sum


## Description

Get sum value


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_sum
```


## Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to
 Int64 before summing to prevent overflow issues.


## Value

Expr


## Examples

```r
pl$DataFrame(list(x=c(1L,NA,2L)))$select(pl$col("x")$sum())#is i32 3 (Int32 not casted)
```


