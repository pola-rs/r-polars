# Rolling skew

```r
Expr_rolling_skew(window_size, bias = TRUE)
```

## Arguments

- `window_size`: integerish, Size of the rolling window
- `bias`: bool default = TRUE, If False, then the calculations are corrected for statistical bias.

## Returns

Expr

Compute a rolling skew.

## Details

Extra comments copied from rust-polars_0.25.1 Compute the sample skewness of a data set.

For normally distributed data, the skewness should be about zero. For uni-modal continuous distributions, a skewness value greater than zero means that there is more weight in the right tail of the distribution. The function `skewtest` can be used to determine if the skewness value is close enough to zero, statistically speaking. see: https://github.com/scipy/scipy/blob/47bb6febaa10658c72962b9615d5d5aa2513fa3a/scipy/stats/stats.py#L1024

## Examples

```r
pl$DataFrame(list(a=iris$Sepal.Length))$select(pl$col("a")$rolling_skew(window_size = 4 )$head(10))
```