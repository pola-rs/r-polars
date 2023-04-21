# Rolling skew

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

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

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='va'>iris</span><span class='op'>$</span><span class='va'>Sepal.Length</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>rolling_skew</span><span class='op'>(</span>window_size <span class='op'>=</span> <span class='fl'>4</span> <span class='op'>)</span><span class='op'>$</span><span class='fu'>head</span><span class='op'>(</span><span class='fl'>10</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (10, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.278031  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.493382  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.0       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.278031  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ -0.186618 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────┘</span>
 </code></pre>