# Set_sorted

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

```r
Expr_set_sorted(reverse = FALSE)
```

## Arguments

- `reverse`: bool if TRUE Descending else Ascending

## Returns

Expr

Flags the expression as 'sorted'.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#correct use flag something correctly as ascendingly sorted</span></span></span>
<span class='r-in'><span><span class='va'>s</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>set_sorted</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>get_column</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s</span><span class='op'>$</span><span class='va'>flags</span> <span class='co'># see flags</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $SORTED_ASC</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $SORTED_DESC</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#incorrect use, flag somthing as not sorted ascendingly</span></span></span>
<span class='r-in'><span><span class='va'>s2</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='fl'>3</span>,<span class='fl'>2</span>,<span class='fl'>4</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>set_sorted</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>get_column</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s2</span><span class='op'>$</span><span class='fu'>sort</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#sorting skipped, although not actually sorted</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (4,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'a' [f64]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1.0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	3.0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2.0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	4.0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>