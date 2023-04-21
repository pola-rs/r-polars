data

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

# 10-base log

## Format

a method

```r
Expr_log10
```

## Returns

Expr

Compute the base 10 logarithm of the input array, element-wise.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a <span class='op'>=</span> <span class='fl'>10</span><span class='op'>^</span><span class='op'>(</span><span class='op'>-</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>log10</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ -1.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┘</span>
 </code></pre>