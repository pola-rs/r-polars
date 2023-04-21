# Series_floor

```r
Series_floor()
```

## Returns

numeric

Floor of this Series

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>.5</span>,<span class='fl'>1.999</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>floor</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (2,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [f64]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	0.0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1.0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>