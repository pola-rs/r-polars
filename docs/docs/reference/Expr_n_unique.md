data

# Count number of unique values

## Format

An object of class `character` of length 1.

```r
Expr_n_unique
```

## Returns

Expr

Count number of unique values. Similar to R length(unique(x))

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Species"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>n_unique</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Species │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ u32     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────┘</span>
 </code></pre>