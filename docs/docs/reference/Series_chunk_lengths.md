data

# Lengths of Series memory chunks

## Format

An object of class `character` of length 1.

```r
Series_chunk_lengths
```

## Returns

numeric vector. Length is number of chunks. Sum of lengths is equal to size of Series.

Get the Lengths of Series memory chunks as vector.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>chunked_series</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span>,<span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>10</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>chunked_series</span><span class='op'>$</span><span class='fu'>chunk_lengths</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1]  3 10</span>
 </code></pre>