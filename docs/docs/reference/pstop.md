# Internal preferred function to throw errors

*Source: [R/rust_result.R](https://github.com/pola-rs/r-polars/tree/main/R/rust_result.R)*

```r
pstop(err, call = sys.call(1L))
```

## Arguments

- `err`: error msg string
- `call`: calling context

## Returns

throws an error

DEPRECATED USE stopf instead

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>f</span> <span class='op'>=</span> <span class='kw'>function</span><span class='op'>(</span><span class='op'>)</span> <span class='fu'>polars</span><span class='fu'>:::</span><span class='fu'><a href='https://rdrr.io/pkg/polars/man/pstop.html'>pstop</a></span><span class='op'>(</span><span class='st'>"this aint right!!"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='kw'><a href='https://rdrr.io/r/base/conditions.html'>tryCatch</a></span><span class='op'>(</span><span class='fu'>f</span><span class='op'>(</span><span class='op'>)</span>, error <span class='op'>=</span> \<span class='op'>(</span><span class='va'>e</span><span class='op'>)</span> <span class='fu'><a href='https://rdrr.io/r/base/character.html'>as.character</a></span><span class='op'>(</span><span class='va'>e</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "Error: Internal error: cannot unwrap non result\n"</span>
 </code></pre>