# Natural Log

```r
Expr_log(base = base::exp(1))
```

## Arguments

- `base`: numeric base value for log, default base::exp(1)

## Returns

Expr

Compute the base x logarithm of the input array, element-wise.

## Examples

```r
pl$DataFrame(list(a = exp(1)^(-1:3)))$select(pl$col("a")$log())
```