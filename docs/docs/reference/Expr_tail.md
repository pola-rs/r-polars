# Tail

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

```r
Expr_tail(n = 10)
```

## Arguments

- `n`: numeric number of elements to select from tail

## Returns

Expr

Get the tail n elements. Similar to R tail(x)

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#get 3 last elements</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>x<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>11</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"x"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>tail</span><span class='op'>(</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ x   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 9   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 10  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 11  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
 </code></pre>