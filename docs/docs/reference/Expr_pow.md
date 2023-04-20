# Exponentiation `^` or `**`

```r
Expr_pow(exponent)
```

## Arguments

- `exponent`: exponent

## Returns

Expr

Raise expression to the power of exponent.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a<span class='op'>=</span> <span class='op'>-</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>pow</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>get_column</span><span class='op'>(</span><span class='st'>"literal"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span><span class='op'>==</span> <span class='fl'>2</span><span class='op'>^</span><span class='op'>(</span><span class='op'>-</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE TRUE TRUE TRUE TRUE</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a <span class='op'>=</span> <span class='op'>-</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>2</span><span class='op'>)</span> <span class='op'>^</span> <span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>get_column</span><span class='op'>(</span><span class='st'>"literal"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span><span class='op'>==</span> <span class='fl'>2</span><span class='op'>^</span><span class='op'>(</span><span class='op'>-</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE TRUE TRUE TRUE TRUE</span>
 </code></pre>