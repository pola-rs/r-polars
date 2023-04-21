# duplicate and concatenate a series

## Format

method

```r
Series_rep(n, rechunk = TRUE)
```

## Arguments

- `n`: number of times to repeat
- `rechunk`: bool default true, reallocate object in memory. If FALSE the Series will take up less space, If TRUE calculations might be faster.

## Returns

bool

duplicate and concatenate a series

## Details

This function in not implemented in pypolars

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,<span class='st'>"bob"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>rep</span><span class='op'>(</span><span class='fl'>3</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (6,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'bob' [i32]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>