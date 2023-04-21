# Extend_expr

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

## Format

Method

```r
Expr_extend_expr(value, n)
```

## Arguments

- `value`: The expr to extend the Series with. This value may be None to fill with nulls.
- `n`: The number of values to extend.

## Returns

Expr

Extend the Series with a expression repeated a number of times

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"5"</span>,<span class='st'>"Bob_is_not_a_number"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>UInt64</span>, strict <span class='op'>=</span> <span class='cn'>FALSE</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='op'>$</span><span class='fu'>extend_expr</span><span class='op'>(</span><span class='fl'>10.1</span>, <span class='fl'>2</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (4, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ u64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 10   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 10   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"5"</span>,<span class='st'>"Bob_is_not_a_number"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>Utf8</span>, strict <span class='op'>=</span> <span class='cn'>FALSE</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='op'>$</span><span class='fu'>extend_expr</span><span class='op'>(</span><span class='st'>"chuchu"</span>, <span class='fl'>2</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (4, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │                     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str                 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5                   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Bob_is_not_a_number │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ chuchu              │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ chuchu              │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────┘</span>
 </code></pre>