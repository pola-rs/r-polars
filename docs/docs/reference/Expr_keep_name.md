data

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

# Keep the original root name of the expression.

## Format

a method

```r
Expr_keep_name
```

## Returns

Expr

Keep the original root name of the expression.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>alice<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"alice"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"bob"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>keep_name</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ alice │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┘</span>
 </code></pre>