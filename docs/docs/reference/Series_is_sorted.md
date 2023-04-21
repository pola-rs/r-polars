# is_sorted

*Source: [R/series__series.R](https://github.com/pola-rs/r-polars/tree/main/R/series__series.R)*

```r
Series_is_sorted(reverse = FALSE, nulls_last = NULL)
```

## Arguments

- `reverse`: order sorted
- `nulls_last`: bool where to keep nulls, default same as reverse

## Returns

DataType

is_sorted

## Details

property sorted flags are not settable, use set_sorted

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_sorted</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
 </code></pre>