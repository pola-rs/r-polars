data

# Compute the exponential, element-wise.

## Format

a method

```r
Expr_exp
```

## Returns

Expr

Compute the exponential, element-wise.

## Examples

```r
log10123 = suppressWarnings(log(-1:3))
all.equal(
  pl$DataFrame(list(a = log10123))$select(pl$col("a")$exp())$as_data_frame()$a,
  exp(1)^log10123
)
```