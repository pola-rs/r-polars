data

# To physical representation

## Format

An object of class `character` of length 1.

```r
Expr_to_physical
```

## Returns

Expr

expression request underlying physical base representation

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>vals <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a"</span>, <span class='st'>"x"</span>, <span class='cn'>NA</span>, <span class='st'>"a"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"vals"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Categorical</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"vals"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Categorical</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>to_physical</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"vals_physical"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬───────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ vals ┆ vals_physical │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cat  ┆ u32           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═══════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a    ┆ 0             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ x    ┆ 1             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a    ┆ 0             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴───────────────┘</span>
 </code></pre>