# Are Series's equal?

## Format

method

```r
Series_series_equal(other, null_equal = FALSE, strict = FALSE)
```

## Arguments

- `other`: Series to compare with
- `null_equal`: bool if TRUE, (Null==Null) is true and not Null/NA. Overridden by strict.
- `strict`: bool if TRUE, do not allow similar DataType comparison. Overrides null_equal.

## Returns

bool

Check if series is equal with another Series.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span>,<span class='st'>"bob"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>series_equal</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
 </code></pre>