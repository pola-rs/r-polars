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

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span> a<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>,<span class='fl'>2</span><span class='op'>:</span><span class='fl'>1</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>skew</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (1, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.343622 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────┘</span>
 </code></pre>