# Print a polars Field

*Source: [R/Field.R](https://github.com/pola-rs/r-polars/tree/main/R/Field.R)*

```r
RField_print()
```

## Returns

self

Print a polars Field

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Field</span><span class='op'>(</span><span class='st'>"foo"</span>,<span class='va'>pl</span><span class='op'>$</span><span class='fu'>List</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>UInt64</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Field {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     name: "foo",</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     dtype: List(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         UInt64,</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     ),</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> }</span>
 </code></pre>