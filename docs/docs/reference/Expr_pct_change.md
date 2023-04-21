# Pct change

```r
Expr_pct_change(n = 1)
```

## Arguments

- `n`: periods to shift for forming percent change.

## Returns

Expr

Computes percentage change between values. Percentage change (as fraction) between current element and most-recent non-null element at least `n` period(s) before the current element. Computes the change from the previous row by default.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span> a<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>10L</span>, <span class='fl'>11L</span>, <span class='fl'>12L</span>, <span class='cn'>NA_integer_</span>, <span class='fl'>12L</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>pct_change</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"pct_change"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a    ┆ pct_change │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32  ┆ f64        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 10   ┆ null       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 11   ┆ 0.1        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 12   ┆ 0.090909   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ 0.0        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 12   ┆ 0.0        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴────────────┘</span>
 </code></pre>