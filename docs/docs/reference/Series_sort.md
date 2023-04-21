# Sort this Series

*Source: [R/series__series.R](https://github.com/pola-rs/r-polars/tree/main/R/series__series.R)*

```r
Series_sort(reverse = FALSE, in_place = FALSE)
```

## Arguments

- `reverse`: bool reverse(descending) sort
- `in_place`: bool sort mutable in-place, breaks immutability If true will throw an error unless this option has been set: `pl$set_polars_options(strictly_immutable = FALSE)`

## Returns

Series

Sort this Series

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='cn'>NA</span>,<span class='cn'>NaN</span>,<span class='cn'>Inf</span>,<span class='op'>-</span><span class='cn'>Inf</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (5,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [f64]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	null</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	-inf</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1.0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	inf</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	NaN</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>