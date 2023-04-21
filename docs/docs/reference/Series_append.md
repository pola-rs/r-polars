# append (default immutable)

```r
Series_append(other, immutable = TRUE)
```

## Arguments

- `other`: Series to append
- `immutable`: bool should append be immutable, default TRUE as mutable operations should be avoided in plain R API's.

## Returns

Series

append two Series, see details for mutability

## Details

if immutable = FLASE, the Series object will not behave as immutable. This mean appending to this Series will affect any variable pointing to this memory location. This will break normal scoping rules of R. Polars-clones are cheap. Mutable operations are likely never needed in any sense.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#default immutable behaviour, s_imut and s_imut_copy stay the same</span></span></span>
<span class='r-in'><span><span class='va'>s_imut</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s_imut_copy</span> <span class='op'>=</span> <span class='va'>s_imut</span></span></span>
<span class='r-in'><span><span class='va'>s_new</span> <span class='op'>=</span> <span class='va'>s_imut</span><span class='op'>$</span><span class='fu'>append</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/identical.html'>identical</a></span><span class='op'>(</span><span class='va'>s_imut</span><span class='op'>$</span><span class='fu'>to_vector</span><span class='op'>(</span><span class='op'>)</span>,<span class='va'>s_imut_copy</span><span class='op'>$</span><span class='fu'>to_vector</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#pypolars-like mutable behaviour,s_mut_copy become the same as s_new</span></span></span>
<span class='r-in'><span><span class='va'>s_mut</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s_mut_copy</span> <span class='op'>=</span> <span class='va'>s_mut</span></span></span>
<span class='r-in'><span> <span class='co'>#must deactivate this to allow to use immutable=FALSE</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>set_polars_options</span><span class='op'>(</span>strictly_immutable <span class='op'>=</span> <span class='cn'>FALSE</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $strictly_immutable</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span><span class='va'>s_new</span> <span class='op'>=</span> <span class='va'>s_mut</span><span class='op'>$</span><span class='fu'>append</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span>,immutable<span class='op'>=</span> <span class='cn'>FALSE</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/identical.html'>identical</a></span><span class='op'>(</span><span class='va'>s_new</span><span class='op'>$</span><span class='fu'>to_vector</span><span class='op'>(</span><span class='op'>)</span>,<span class='va'>s_mut_copy</span><span class='op'>$</span><span class='fu'>to_vector</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
 </code></pre>