# wrap as Expression capture ok/err as result

```r
wrap_e_result(e, str_to_lit = TRUE, argname = NULL)
```

## Arguments

- `e`: an Expr(polars) or any R expression
- `str_to_lit`: bool should string become a column name or not, then a literal string
- `argname`: if error, blame argument of this name

## Returns

Expr

wrap as Expression capture ok/err as result

## Details

used internally to ensure an object is an expression and to catch any error

## Examples

```r
pl$col("foo") < 5
```