# Append expressions

## Format

a method

```r
Expr_append(other, upcast = TRUE)
```

## Arguments

- `other`: Expr, into Expr
- `upcast`: bool upcast to, if any supertype of two non equal datatypes.

## Returns

Expr

This is done by adding the chunks of `other` to this `output`.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#append bottom to to row</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a <span class='op'>=</span> <span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>, b <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>NA_real_</span>,<span class='fl'>4</span>,<span class='fl'>5</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>head</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>append</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>tail</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   ┆ b    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ null │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   ┆ 5.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴──────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#implicit upcast, when default = TRUE</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>42</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>append</span><span class='op'>(</span><span class='fl'>42L</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ literal │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 42.0    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 42.0    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────┘</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>42</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>append</span><span class='op'>(</span><span class='cn'>FALSE</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ literal │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 42.0    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.0     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────┘</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='st'>"Bob"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>append</span><span class='op'>(</span><span class='cn'>FALSE</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ literal │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Bob     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────┘</span>
 </code></pre>