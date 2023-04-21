# Div

```r
Expr_div(other)

## S3 method for class 'Expr'
e1 / e2
```

## Arguments

- `other`: literal or Robj which can become a literal
- `e1`: lhs Expr
- `e2`: rhs Expr or anything which can become a literal Expression

## Returns

Exprs

Divide

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#three syntaxes same result</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>5</span><span class='op'>)</span> <span class='op'>/</span> <span class='fl'>10</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: [(5f64) / (10f64)]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>5</span><span class='op'>)</span> <span class='op'>/</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>10</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: [(5f64) / (10f64)]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>div</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>10</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: [(5f64) / (10f64)]</span>
 </code></pre>