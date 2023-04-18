data

# Index of min value

## Format

a method

```r
Expr_arg_min
```

## Returns

Expr

Get the index of the minimal value.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$DataFrame(list(
  a = c(6, 1, 0, NA, Inf, NaN)
))$select(pl$col("a")$arg_min())
```