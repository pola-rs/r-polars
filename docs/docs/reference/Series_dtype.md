# Get data type of Series

```r
Series_dtype()

Series_flags()
```

## Returns

DataType

DataType

Get data type of Series

Get data type of Series

## Details

property sorted flags are not settable, use set_sorted

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dtype</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Int32</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='fl'>2</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dtype</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Float64</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='va'>letters</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dtype</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Utf8</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='va'>flags</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $SORTED_ASC</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $SORTED_DESC</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>