# Immutable combine series

```r
## S3 method for class 'Series'
c(x, ...)
```

## Arguments

- `x`: a Series
- `...`: Series(s) or any object into Series meaning `pl$Series(object)` returns a series

## Returns

a combined Series

Immutable combine series

## Details

append datatypes has to match. Combine does not rechunk. Read more about R vectors, Series and chunks in `docs_translations`:

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>s</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span>,<span class='fl'>3</span><span class='op'>:</span><span class='fl'>1</span>,<span class='cn'>NA_integer_</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s</span><span class='op'>$</span><span class='fu'>chunk_lengths</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#the series contain three unmerged chunks</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 5 3 1</span>
 </code></pre>