data

*Source: [R/series__series.R](https://github.com/pola-rs/r-polars/tree/main/R/series__series.R)*

# Sum

## Format

An object of class `character` of length 1.

```r
Series_sum
```

## Returns

Series

Reduce Series with sum

## Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to prevent overflow issues.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,<span class='cn'>NA</span>,<span class='fl'>3</span>,<span class='fl'>5</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='op'>)</span> <span class='co'># a NA is dropped always</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [f64]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	11.0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,<span class='cn'>NA</span>,<span class='fl'>3</span>,<span class='cn'>NaN</span>,<span class='fl'>4</span>,<span class='cn'>Inf</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='op'>)</span> <span class='co'># NaN carries / poisons</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [f64]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	NaN</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,<span class='fl'>3</span>,<span class='cn'>Inf</span>,<span class='fl'>4</span>,<span class='op'>-</span><span class='cn'>Inf</span>,<span class='fl'>5</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='op'>)</span> <span class='co'># Inf-Inf is NaN</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [f64]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	NaN</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>