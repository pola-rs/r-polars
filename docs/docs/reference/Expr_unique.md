# get unqie values

```r
Expr_unique(maintain_order = FALSE)
```

## Arguments

- `maintain_order`: bool, if TRUE guranteed same order, if FALSE maybe

## Returns

Expr

Get unique values of this expression. Similar to R unique()

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Species"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>unique</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Species    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cat        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ setosa     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ versicolor │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ virginica  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────┘</span>
 </code></pre>