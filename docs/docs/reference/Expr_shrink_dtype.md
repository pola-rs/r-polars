data

# Wrap column in list

## Format

An object of class `character` of length 1.

```r
Expr_shrink_dtype
```

## Returns

Expr

Shrink numeric columns to the minimal required datatype. Shrink to the dtype needed to fit the extrema of this `[Series]`. This can be used to reduce memory pressure.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>   a<span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1L</span>, <span class='fl'>2L</span>, <span class='fl'>3L</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>   b<span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1L</span>, <span class='fl'>2L</span>, <span class='fu'><a href='https://rdrr.io/r/base/bitwise.html'>bitwShiftL</a></span><span class='op'>(</span><span class='fl'>2L</span>,<span class='fl'>29</span><span class='op'>)</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>   c<span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='op'>-</span><span class='fl'>1L</span>, <span class='fl'>2L</span>, <span class='fu'><a href='https://rdrr.io/r/base/bitwise.html'>bitwShiftL</a></span><span class='op'>(</span><span class='fl'>1L</span>,<span class='fl'>15</span><span class='op'>)</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>   d<span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='op'>-</span><span class='fl'>112L</span>, <span class='fl'>2L</span>, <span class='fl'>112L</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>   e<span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='op'>-</span><span class='fl'>112L</span>, <span class='fl'>2L</span>, <span class='fl'>129L</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>   f<span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a"</span>, <span class='st'>"b"</span>, <span class='st'>"c"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>   g<span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>0.1</span>, <span class='fl'>1.32</span>, <span class='fl'>0.12</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>   h<span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>, <span class='cn'>NA</span>, <span class='cn'>FALSE</span><span class='op'>)</span></span></span>
<span class='r-in'><span> <span class='op'>)</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"b"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Int64</span><span class='op'>)</span> <span class='op'>*</span><span class='fl'>32L</span></span></span>
<span class='r-in'><span> <span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>shrink_dtype</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 8)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────────────┬───────┬──────┬──────┬─────┬──────┬───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   ┆ b           ┆ c     ┆ d    ┆ e    ┆ f   ┆ g    ┆ h     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---         ┆ ---   ┆ ---  ┆ ---  ┆ --- ┆ ---  ┆ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i8  ┆ i64         ┆ i32   ┆ i8   ┆ i16  ┆ str ┆ f32  ┆ bool  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════════════╪═══════╪══════╪══════╪═════╪══════╪═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ 32          ┆ -1    ┆ -112 ┆ -112 ┆ a   ┆ 0.1  ┆ true  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ 64          ┆ 2     ┆ 2    ┆ 2    ┆ b   ┆ 1.32 ┆ null  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   ┆ 34359738368 ┆ 32768 ┆ 112  ┆ 129  ┆ c   ┆ 0.12 ┆ false │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────────────┴───────┴──────┴──────┴─────┴──────┴───────┘</span>
 </code></pre>