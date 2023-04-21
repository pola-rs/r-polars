data

# aggregate groups

## Format

An object of class `character` of length 1.

```r
Expr_agg_groups
```

## Returns

Exprs

Get the group indexes of the group by operation. Should be used in aggregation context only.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  group <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"one"</span>,<span class='st'>"one"</span>,<span class='st'>"one"</span>,<span class='st'>"two"</span>,<span class='st'>"two"</span>,<span class='st'>"two"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  value <span class='op'>=</span>  <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>94</span>, <span class='fl'>95</span>, <span class='fl'>96</span>, <span class='fl'>97</span>, <span class='fl'>97</span>, <span class='fl'>99</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>groupby</span><span class='op'>(</span><span class='st'>"group"</span>, maintain_order<span class='op'>=</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>agg</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"value"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>agg_groups</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┬───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ group ┆ value     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   ┆ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str   ┆ list[u32] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╪═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ one   ┆ [0, 1, 2] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ two   ┆ [3, 4, 5] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┴───────────┘</span>
 </code></pre>