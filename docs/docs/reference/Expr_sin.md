data

# Sin

## Format

Method

```r
Expr_sin
```

## Returns

Expr

Compute the element-wise value for the sine.

## Details

Evaluated Series has dtype Float64

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>0</span>,<span class='va'>pi</span><span class='op'>/</span><span class='fl'>2</span>,<span class='va'>pi</span>,<span class='cn'>NA_real_</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sin</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.0        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.2246e-16 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────┘</span>
 </code></pre>