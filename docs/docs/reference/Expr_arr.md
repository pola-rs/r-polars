# arr: list related methods

```r
Expr_arr()
```

## Returns

Expr

Create an object namespace of all list related methods. See the individual method pages for full details

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df_with_list</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  group <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='fl'>1</span>,<span class='fl'>2</span>,<span class='fl'>2</span>,<span class='fl'>3</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  value <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>groupby</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='st'>"group"</span>,maintain_order <span class='op'>=</span> <span class='cn'>TRUE</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>agg</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"value"</span><span class='op'>)</span> <span class='op'>*</span> <span class='fl'>3L</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df_with_list</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"value"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>lengths</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"group_size"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (3, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┬───────────┬────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ group ┆ value     ┆ group_size │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   ┆ ---       ┆ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64   ┆ list[i32] ┆ u32        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╪═══════════╪════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0   ┆ [3, 6]    ┆ 2          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2.0   ┆ [9, 12]   ┆ 2          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.0   ┆ [15]      ┆ 1          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┴───────────┴────────────┘</span>
 </code></pre>