# `Expr_cumprod`

Cumulative product


## Description

Get an array with the cumulative product computed at every element.


## Format

a method


## Usage

```r
Expr_cumprod(reverse = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
`reverse`     |     bool, default FALSE, if true roll over vector from back to forth


## Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to
 Int64 before summing to prevent overflow issues.


## Value

Expr


## Examples

```r
pl$DataFrame(list(a=1:4))$select(
pl$col("a")$cumprod()$alias("cumprod"),
pl$col("a")$cumprod(reverse=TRUE)$alias("cumprod_reversed")
)
```


