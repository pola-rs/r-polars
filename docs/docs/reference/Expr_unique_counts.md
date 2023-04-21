data

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

# Value counts

## Format

Method

```r
Expr_unique_counts
```

## Returns

Expr

Return a count of the unique values in the order of appearance. This method differs from `value_counts` in that it does not return the values, only the counts and might be faster

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Species"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>unique_counts</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Species │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ u32     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 50      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 50      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 50      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────┘</span>
 </code></pre>