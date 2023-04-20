data

# Not !

## Format

An object of class `character` of length 1.

```r
Expr_is_not(other)

## S3 method for class 'Expr'
!x
```

## Arguments

- `x`: Expr
- `other`: literal or Robj which can become a literal

## Returns

Exprs

not method and operator

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#two syntaxes same result</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_not</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: true.is_not()</span>
<span class='r-in'><span><span class='op'>!</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='cn'>TRUE</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: true.is_not()</span>
 </code></pre>