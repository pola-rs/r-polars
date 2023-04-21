# Reverse exponentiation `%**%`(in R `** == ^`)

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

```r
Expr_rpow(base)

e1 %**% e2

`%**%.Expr`(e1, e2)
```

## Arguments

- `base`: real or Expr, the value of the base, self is the exponent
- `e1`: value where ** operator is defined
- `e2`: value where ** operator is defined

## Returns

Expr

Raise a base to the power of the expression as exponent.

## Details

do not use `**`, R secretly parses that just as if it was a `^`

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a <span class='op'>=</span> <span class='op'>-</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>rpow</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>get_column</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span> <span class='op'>==</span>  <span class='op'>(</span><span class='op'>-</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>^</span><span class='fl'>2</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE TRUE TRUE TRUE TRUE</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a <span class='op'>=</span> <span class='op'>-</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>2</span><span class='op'>)</span> <span class='op'>%**%</span> <span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>get_column</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span> <span class='op'>==</span>  <span class='op'>(</span><span class='op'>-</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>^</span><span class='fl'>2</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE TRUE TRUE TRUE TRUE</span>
 </code></pre>