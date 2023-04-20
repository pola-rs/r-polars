# Simple SQL CASE WHEN implementation for R

```r
pcase(..., or_else = NULL)
```

## Arguments

- `...`: odd arugments are bool statements, a next even argument is returned if prior bool statement is the first true
- `or_else`: return this if no bool statements were true

## Returns

any return given first true bool statement otherwise value of or_else

Inspired by data.table::fcase + dplyr::case_when. Used instead of base::switch internally.

## Details

Lifecycle: perhaps replace with something written in rust to speed up a bit

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>n</span> <span class='op'>=</span> <span class='fl'>7</span></span></span>
<span class='r-in'><span><span class='fu'>polars</span><span class='fu'>:::</span><span class='fu'><a href='https://rdrr.io/pkg/polars/man/pcase.html'>pcase</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span> <span class='va'>n</span><span class='op'>&lt;</span><span class='fl'>5</span>,<span class='st'>"nope"</span>,</span></span>
<span class='r-in'><span> <span class='va'>n</span><span class='op'>&gt;</span><span class='fl'>6</span>,<span class='st'>"yeah"</span>,</span></span>
<span class='r-in'><span> or_else <span class='op'>=</span> <span class='fu'>stopf</span><span class='op'>(</span><span class='st'>"failed to have a case for n=%s"</span>,<span class='va'>n</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "yeah"</span>
 </code></pre>