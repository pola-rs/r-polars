# DataFrame_unique

```r
DataFrame_unique(subset = NULL, keep = "first")
```

## Arguments

- `subset`: string or vector of strings. Column name(s) to consider when identifying duplicates. If set to NULL (default), use all columns.
- `keep`: string. Which of the duplicate rows to keep:
    
     * "first": Keep first unique row.
     * "last": Keep last unique row.
     * "none": Don’t keep duplicate rows.

## Returns

DataFrame

Drop duplicate rows from this dataframe.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  x <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/numeric.html'>as.numeric</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>, <span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  y <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/numeric.html'>as.numeric</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>, <span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  z <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/numeric.html'>as.numeric</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>, <span class='fl'>1</span>, <span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>unique</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='va'>height</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 5</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>unique</span><span class='op'>(</span>subset <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"x"</span>, <span class='st'>"z"</span><span class='op'>)</span>, keep <span class='op'>=</span> <span class='st'>"last"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>height</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 5</span>
 </code></pre>