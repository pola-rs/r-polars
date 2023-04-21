data

# Tanh

## Format

Method

```r
Expr_tanh
```

## Returns

Expr

Compute the element-wise value for the hyperbolic tangent.

## Details

Evaluated Series has dtype Float64

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='op'>-</span><span class='fl'>1</span>,<span class='fu'><a href='https://rdrr.io/r/base/Hyperbolic.html'>atanh</a></span><span class='op'>(</span><span class='fl'>0.5</span><span class='op'>)</span>,<span class='fl'>0</span>,<span class='fl'>1</span>,<span class='cn'>NA_real_</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>tanh</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ -0.761594 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.5       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.0       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.761594  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────┘</span>
 </code></pre>