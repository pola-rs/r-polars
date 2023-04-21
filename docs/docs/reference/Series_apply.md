# Apply every value with an R fun

*Source: [R/series__series.R](https://github.com/pola-rs/r-polars/tree/main/R/series__series.R)*

```r
Series_apply(
  fun,
  datatype = NULL,
  strict_return_type = TRUE,
  allow_fail_eval = FALSE
)
```

## Arguments

- `fun`: r function, should take a scalar value as input and return one.
- `datatype`: DataType of return value. Default NULL means same as input.
- `strict_return_type`: bool, default TRUE: fail on wrong return type, FALSE: convert to polars Null
- `allow_fail_eval`: bool, default FALSE: raise R fun error, TRUE: convert to polars Null

## Returns

Series

About as slow as regular non-vectorized R. Similar to using R sapply on a vector.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>s</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='va'>letters</span><span class='op'>[</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>]</span>,<span class='st'>"ltrs"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>f</span> <span class='op'>=</span> \<span class='op'>(</span><span class='va'>x</span><span class='op'>)</span> <span class='fu'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='op'>(</span><span class='va'>x</span>,<span class='st'>":"</span>,<span class='fu'><a href='https://rdrr.io/r/base/integer.html'>as.integer</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/rawConversion.html'>charToRaw</a></span><span class='op'>(</span><span class='va'>x</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s</span><span class='op'>$</span><span class='fu'>apply</span><span class='op'>(</span><span class='va'>f</span>,<span class='va'>pl</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (5,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'ltrs_apply' [str]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"a : 97"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"b : 98"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"c : 99"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"d : 100"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"e : 101"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#same as</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/lapply.html'>sapply</a></span><span class='op'>(</span><span class='va'>s</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span>,<span class='va'>f</span><span class='op'>)</span>,<span class='va'>s</span><span class='op'>$</span><span class='va'>name</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (5,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'ltrs' [str]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"a : 97"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"b : 98"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"c : 99"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"d : 100"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"e : 101"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>