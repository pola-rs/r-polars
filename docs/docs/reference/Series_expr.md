# Any expr method on a Series

*Source: [R/series__series.R](https://github.com/pola-rs/r-polars/tree/main/R/series__series.R)*

```r
Series_expr()
```

## Returns

Expr

Call an expression on a Series See the individual Expr method pages for full details

## Details

This is a shorthand of writing something like `pl$DataFrame(s)$select(pl$col("sname")$expr)$to_series(0)`

This subnamespace is experimental. Submit an issue if anything unexpected happend.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>s</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>,<span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,<span class='cn'>NULL</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s</span><span class='op'>$</span><span class='va'>expr</span><span class='op'>$</span><span class='fu'>first</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [list[i32]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	[1, 2, 3]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>s</span><span class='op'>$</span><span class='va'>expr</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"alice"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (3,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'alice' [list[i32]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	[1, 2, 3]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	[1, 2]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	[]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>