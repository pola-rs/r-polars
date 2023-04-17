# `Expr_skew`

Skewness


## Description

Compute the sample skewness of a data set.


## Usage

```r
Expr_skew(bias = TRUE)
```


## Arguments

Argument      |Description
------------- |----------------
`bias`     |     If False, then the calculations are corrected for statistical bias.


## Details

For normally distributed data, the skewness should be about zero. For
 unimodal continuous distributions, a skewness value greater than zero means
 that there is more weight in the right tail of the distribution. The
 function `skewtest` can be used to determine if the skewness value
 is close enough to zero, statistically speaking.
 
 See scipy.stats for more information.
 list(list("Notes"), list("\n", "\n", "The sample skewness is computed as the Fisher-Pearson coefficient\n", "of skewness, i.e.\n", "\n", list(list(" g_1=\\frac{m_3}{m_2^{3/2}}")), "\n", "\n", "where\n", "\n", list(list(" m_i=\\frac{1}{N}\\sum_{n=1}^N(x[n]-\\bar{x})^i")), "\n", "\n", "is the biased sample :math:", list("i\\texttt{th}"), " central moment, and ", list(list("\\bar{x}")), " is\n", "the sample mean.  If ", list("bias"), " is False, the calculations are\n", "corrected for bias and the value computed is the adjusted\n", 
    "Fisher-Pearson standardized moment coefficient, i.e.\n", "\n", list(list(" G_1 = \\frac{k_3}{k_2^{3/2}} = \\frac{\\sqrt{N(N-1)}}{N-2}\\frac{m_3}{m_2^{3/2}}")), "\n"))


## Value

Expr


## References

https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.skew.html?highlight=skew#scipy.stats.skew


## Examples

```r
df = pl$DataFrame(list( a=c(1:3,2:1)))
df$select(pl$col("a")$skew())
```


