# get/set Field name

*Source: [R/Field.R](https://github.com/pola-rs/r-polars/tree/main/R/Field.R)*

```r
RField_name()
```

## Returns

name

get/set Field name

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>field</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Field</span><span class='op'>(</span><span class='st'>"Cities"</span>,<span class='va'>pl</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#get name / datatype</span></span></span>
<span class='r-in'><span><span class='va'>field</span><span class='op'>$</span><span class='va'>name</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "Cities"</span>
<span class='r-in'><span><span class='va'>field</span><span class='op'>$</span><span class='va'>datatype</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Utf8</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#set + get values</span></span></span>
<span class='r-in'><span><span class='va'>field</span><span class='op'>$</span><span class='va'>name</span> <span class='op'>=</span> <span class='st'>"CityPoPulations"</span> <span class='co'>#&lt;- is fine too</span></span></span>
<span class='r-in'><span><span class='va'>field</span><span class='op'>$</span><span class='va'>datatype</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='va'>UInt32</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>field</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Field {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     name: "CityPoPulations",</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     dtype: UInt32,</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> }</span>
 </code></pre>