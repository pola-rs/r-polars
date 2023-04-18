# Entropy

```r
Expr_entropy(base = base::exp(1), normalize = TRUE)
```

## Arguments

- `base`: Given exponential base, defaults to `e`
- `normalize`: Normalize pk if it doesn't sum to 1.

## Returns

Expr

Computes the entropy. Uses the formula `-sum(pk * log(pk))` where `pk` are discrete probabilities. Return Null if input is not values

## Examples

```r
pl$select(pl$lit(c("a","b","b","c","c","c"))$unique_counts()$entropy(base=2))
```