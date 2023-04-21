data

# Xor

## Format

An object of class `character` of length 1.

```r
Expr_xor(other)
```

## Arguments

- `other`: literal or Robj which can become a literal

## Returns

Expr

combine to boolean expresions with XOR

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>xor</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='cn'>FALSE</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: [(true) ^ (false)]</span>
 </code></pre>