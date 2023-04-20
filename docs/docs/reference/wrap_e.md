# wrap as literal

```r
wrap_e(e, str_to_lit = TRUE)
```

## Arguments

- `e`: an Expr(polars) or any R expression

## Returns

Expr

wrap as literal

## Details

used internally to ensure an object is an expression

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"foo"</span><span class='op'>)</span> <span class='op'>&lt;</span> <span class='fl'>5</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: [(col("foo")) &lt; (5f64)]</span>
 </code></pre>