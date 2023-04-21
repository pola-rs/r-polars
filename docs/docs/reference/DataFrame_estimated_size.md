# Estimated size

*Source: [R/dataframe__frame.R](https://github.com/pola-rs/r-polars/tree/main/R/dataframe__frame.R)*

## Format

function

```r
DataFrame_estimated_size
```

## Returns

Bytes

Return an estimation of the total (heap) allocated size of the DataFrame.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>estimated_size</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 2816</span>
 </code></pre>