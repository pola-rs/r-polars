# wrap as literal

```r
wrap_e(e, str_to_lit = TRUE)
```

## Arguments

- `e`: an Expr(polars) or any R expression

## Returns

Expr

wrap as literal

## Details

used internally to ensure an object is an expression

## Examples

```r
pl$col("foo") < 5
```