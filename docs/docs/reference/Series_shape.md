# Shape of series

*Source: [R/series__series.R](https://github.com/pola-rs/r-polars/tree/main/R/series__series.R)*

```r
Series_shape()
```

## Returns

dimension vector of Series

Shape of series

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/identical.html'>identical</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='va'>shape</span>, <span class='fl'>2</span><span class='op'>:</span><span class='fl'>1</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
 </code></pre>