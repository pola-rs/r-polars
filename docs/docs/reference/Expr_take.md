# Take values by index.

## Format

a method

```r
Expr_take(indices)
```

## Arguments

- `indices`: R scalar/vector or Series, or Expr that leads to a UInt32 dtyped Series.

## Returns

Expr

Take values by index.

## Details

similar to R indexing syntax e.g. `letters[c(1,3,5)]`, however as an expression, not as eager computation exceeding

## Examples

```r
pl$select( pl$lit(0:10)$take(c(1,8,0,7)))
```