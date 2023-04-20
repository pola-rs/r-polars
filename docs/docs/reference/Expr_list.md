data

# Wrap column in list

## Format

a method

```r
Expr_list
```

## Returns

Expr

Aggregate to list.

## Details

use to_struct to wrap a DataFrame

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>list</span><span class='op'>(</span><span class='op'>)</span>, <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────────┬─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │               ┆ literal │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---           ┆ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list[i32]     ┆ str     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════════╪═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [1, 2, ... 4] ┆ a       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────────┴─────────┘</span>
 </code></pre>