# Width of DataFrame

*Source: [R/dataframe__frame.R](https://github.com/pola-rs/r-polars/tree/main/R/dataframe__frame.R)*

```r
DataFrame_width()
```

## Returns

width as numeric scalar

Get width(ncol) of DataFrame

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='va'>width</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 5</span>
 </code></pre>