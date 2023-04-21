data

# Or

## Format

An object of class `character` of length 1.

```r
Expr_or(other)
```

## Arguments

- `other`: Expr or into Expr

## Returns

Expr

combine to boolean expresions with OR

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='cn'>TRUE</span><span class='op'>)</span> <span class='op'>|</span> <span class='cn'>FALSE</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: [(true) | (false)]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>or</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: [(true) | (true)]</span>
 </code></pre>