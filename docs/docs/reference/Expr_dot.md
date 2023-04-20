# Dot product

## Format

a method

```r
Expr_dot(other)
```

## Arguments

- `other`: Expr to compute dot product with.

## Returns

Expr

Compute the dot/inner product between two Expressions.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  a<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span>,b<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='fl'>2</span>,<span class='fl'>3</span>,<span class='fl'>4</span><span class='op'>)</span>,c<span class='op'>=</span><span class='st'>"bob"</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>dot</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"b"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"a dot b"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>dot</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"a dot a"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────┬─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a dot b ┆ a dot a │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---     ┆ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64     ┆ i32     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════╪═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 30.0    ┆ 30      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────┴─────────┘</span>
 </code></pre>