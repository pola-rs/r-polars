data

# sum

## Format

An object of class `character` of length 1.

```r
Expr_sum
```

## Returns

Expr

Get sum value

## Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to prevent overflow issues.

## Examples

```r
pl$DataFrame(list(x=c(1L,NA,2L)))$select(pl$col("x")$sum())#is i32 3 (Int32 not casted)
```