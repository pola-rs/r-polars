data

# Rechunk memory layout

## Format

a method

```r
Expr_rechunk
```

## Returns

Expr

Create a single chunk of memory for this Series.

## Details

See rechunk() explained here `docs_translations`

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#get chunked lengths with/without rechunk</span></span></span>
<span class='r-in'><span><span class='va'>series_list</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>,b<span class='op'>=</span><span class='fl'>4</span><span class='op'>:</span><span class='fl'>6</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>append</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"b"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"a_chunked"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>append</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"b"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>rechunk</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"a_rechunked"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>get_columns</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/lapply.html'>lapply</a></span><span class='op'>(</span><span class='va'>series_list</span>, \<span class='op'>(</span><span class='va'>x</span><span class='op'>)</span> <span class='va'>x</span><span class='op'>$</span><span class='fu'>chunk_lengths</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $a_chunked</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 3 3</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $a_rechunked</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 6</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>