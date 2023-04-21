data

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

# is_in

## Format

An object of class `character` of length 1.

```r
Expr_is_in(other)
```

## Arguments

- `other`: literal or Robj which can become a literal

## Returns

Expr

combine to boolean expresions with similar to `%in%`

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#R Na_integer -&gt; polars Null(Int32) is in polars Null(Int32)</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span>,<span class='cn'>NA_integer_</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_in</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='cn'>NA_real_</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_data_frame</span><span class='op'>(</span><span class='op'>)</span><span class='op'>[[</span><span class='fl'>1L</span><span class='op'>]</span><span class='op'>]</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE FALSE FALSE FALSE  TRUE</span>
 </code></pre>