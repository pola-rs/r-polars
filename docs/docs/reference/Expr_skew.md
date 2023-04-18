# Skewness

```r
Expr_skew(bias = TRUE)
```

## Arguments

- `bias`: If False, then the calculations are corrected for statistical bias.

## Returns

Expr

Compute the sample skewness of a data set.

## Details

For normally distributed data, the skewness should be about zero. For unimodal continuous distributions, a skewness value greater than zero means that there is more weight in the right tail of the distribution. The function `skewtest` can be used to determine if the skewness value is close enough to zero, statistically speaking.

See scipy.stats for more information.

## Examples

```r
df = pl$DataFrame(list( a=c(1:3,2:1)))
df$select(pl$col("a")$skew())
```

## References

https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.skew.html?highlight=skew#scipy.stats.skew