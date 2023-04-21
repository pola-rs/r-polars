# Take absolute value of Series

*Source: [R/series__series.R](https://github.com/pola-rs/r-polars/tree/main/R/series__series.R)*

```r
Series_abs()
```

## Returns

Series

Take absolute value of Series

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='op'>-</span><span class='fl'>2</span><span class='op'>:</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>abs</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (5,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [i32]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>