data

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

# Arcsin

## Format

Method

```r
Expr_arcsin
```

## Returns

Expr

Compute the element-wise value for the inverse sine.

## Details

Evaluated Series has dtype Float64

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='op'>-</span><span class='fl'>1</span>,<span class='fu'><a href='https://rdrr.io/r/base/Trig.html'>sin</a></span><span class='op'>(</span><span class='fl'>0.5</span><span class='op'>)</span>,<span class='fl'>0</span>,<span class='fl'>1</span>,<span class='cn'>NA_real_</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>arcsin</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ -1.570796 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.5       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.0       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.570796  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────┘</span>
 </code></pre>