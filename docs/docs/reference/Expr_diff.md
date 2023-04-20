# Diff

```r
Expr_diff(n = 1, null_behavior = "ignore")
```

## Arguments

- `n`: Integerish Number of slots to shift.
- `null_behavior`: option default 'ignore', else 'drop'

## Returns

Expr

Calculate the n-th discrete difference.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span> a<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>20L</span>,<span class='fl'>10L</span>,<span class='fl'>30L</span>,<span class='fl'>40L</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>diff</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"diff_default"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>diff</span><span class='op'>(</span><span class='fl'>2</span>,<span class='st'>"ignore"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"diff_2_ignore"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬───────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ diff_default ┆ diff_2_ignore │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32          ┆ i32           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪═══════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null         ┆ null          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ -10          ┆ null          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 20           ┆ 10            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 10           ┆ 30            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴───────────────┘</span>
 </code></pre>