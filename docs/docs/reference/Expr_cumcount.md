# Cumulative count

## Format

a method

```r
Expr_cumcount(reverse = FALSE)
```

## Arguments

- `reverse`: bool, default FALSE, if true roll over vector from back to forth

## Returns

Expr

Get an array with the cumulative count computed at every element. Counting from 0 to len

## Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to prevent overflow issues.

cumcount does not seem to count within lists.

## Examples

```r
pl$DataFrame(list(a=1:4))$select(
  pl$col("a")$cumcount()$alias("cumcount"),
  pl$col("a")$cumcount(reverse=TRUE)$alias("cumcount_reversed")
)
```