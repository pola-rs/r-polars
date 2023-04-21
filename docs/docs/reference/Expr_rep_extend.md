# extend series with repeated series

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

## Format

Method

```r
Expr_rep_extend(expr, n, rechunk = TRUE, upcast = TRUE)
```

## Arguments

- `expr`: Expr or into Expr
- `n`: Numeric the number of times to repeat, must be non-negative and finite
- `rechunk`: bool default = TRUE, if true memory layout will be rewritten
- `upcast`: bool default = TRUE, passed to self$append(), if TRUE non identical types will be casted to common super type if any. If FALSE or no common super type throw error.

## Returns

Expr

Extend a series with a repeated series or value.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='fl'>2</span>,<span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>rep_extend</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>, n <span class='op'>=</span> <span class='fl'>5</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (18, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ... │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
 </code></pre>