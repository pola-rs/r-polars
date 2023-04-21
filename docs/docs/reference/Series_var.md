# Get the standard deviation of this Series.

*Source: [R/series__series.R](https://github.com/pola-rs/r-polars/tree/main/R/series__series.R)*

## Format

method

```r
Series_var(ddof = 1)
```

## Arguments

- `ddof`: “Delta Degrees of Freedom”: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.

## Returns

bool

Get the standard deviation of this Series.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span>,<span class='st'>"bob"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>var</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 1.666667</span>
 </code></pre>