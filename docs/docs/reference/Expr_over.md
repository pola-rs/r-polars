# over

```r
Expr_over(...)
```

## Arguments

- `...`: of strings or columns to group by

## Returns

Expr

Apply window function over a subgroup. This is similar to a groupby + aggregation + self join. Or similar to `window functions in Postgres<https://www.postgresql.org/docs/current/tutorial-window.html>`_.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  val <span class='op'>=</span> <span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span>,</span></span>
<span class='r-in'><span>  a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"+"</span>,<span class='st'>"+"</span>,<span class='st'>"-"</span>,<span class='st'>"-"</span>,<span class='st'>"+"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  b <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"+"</span>,<span class='st'>"-"</span>,<span class='st'>"+"</span>,<span class='st'>"-"</span>,<span class='st'>"+"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"val"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>count</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>over</span><span class='op'>(</span><span class='st'>"a"</span>,<span class='st'>"b"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ val │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ u32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
 </code></pre>