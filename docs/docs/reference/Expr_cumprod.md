# Cumulative product

## Format

a method

```r
Expr_cumprod(reverse = FALSE)
```

## Arguments

- `reverse`: bool, default FALSE, if true roll over vector from back to forth

## Returns

Expr

Get an array with the cumulative product computed at every element.

## Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to prevent overflow issues.

## Examples

```r
pl$DataFrame(list(a=1:4))$select(
  pl$col("a")$cumprod()$alias("cumprod"),
  pl$col("a")$cumprod(reverse=TRUE)$alias("cumprod_reversed")
)
```