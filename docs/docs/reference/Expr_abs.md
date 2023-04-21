data

# Abs

## Format

An object of class `character` of length 1.

```r
Expr_abs
```

## Returns

Exprs abs

Compute absolute values

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='op'>-</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>1</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span>,<span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>abs</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"abs"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   ┆ abs │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ -1  ┆ 1   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0   ┆ 0   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ 1   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┘</span>
 </code></pre>