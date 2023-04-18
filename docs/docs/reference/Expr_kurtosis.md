# Kurtosis

```r
Expr_kurtosis(fisher = TRUE, bias = TRUE)
```

## Arguments

- `fisher`: bool se details
- `bias`: bool, If FALSE, then the calculations are corrected for statistical bias.

## Returns

Expr

Compute the kurtosis (Fisher or Pearson) of a dataset.

## Details

Kurtosis is the fourth central moment divided by the square of the variance. If Fisher's definition is used, then 3.0 is subtracted from the result to give 0.0 for a normal distribution. If bias is False then the kurtosis is calculated using k statistics to eliminate bias coming from biased moment estimators See scipy.stats for more information

#' See scipy.stats for more information.

## Examples

```r
df = pl$DataFrame(list( a=c(1:3,2:1)))
df$select(pl$col("a")$kurtosis())
```

## References

https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.kurtosis.html?highlight=kurtosis