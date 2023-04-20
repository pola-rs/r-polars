# wrap as Expression capture ok/err as result

```r
wrap_e_result(e, str_to_lit = TRUE, argname = NULL)
```

## Arguments

- `e`: an Expr(polars) or any R expression
- `str_to_lit`: bool should string become a column name or not, then a literal string
- `argname`: if error, blame argument of this name

## Returns

Expr

wrap as Expression capture ok/err as result

## Details

used internally to ensure an object is an expression and to catch any error

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"foo"</span><span class='op'>)</span> <span class='op'>&lt;</span> <span class='fl'>5</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: [(col("foo")) &lt; (5f64)]</span>
 </code></pre>