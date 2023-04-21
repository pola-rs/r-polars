data

# And

## Format

An object of class `character` of length 1.

```r
Expr_and(other)
```

## Arguments

- `other`: literal or Robj which can become a literal

## Returns

Expr

combine to boolean exprresions with AND

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='cn'>TRUE</span><span class='op'>)</span> <span class='op'>&amp;</span> <span class='cn'>TRUE</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: [(true) &amp; (true)]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>and</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: [(true) &amp; (true)]</span>
 </code></pre>