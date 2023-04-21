# Set sorted

*Source: [R/series__series.R](https://github.com/pola-rs/r-polars/tree/main/R/series__series.R)*

```r
Series_set_sorted(reverse = FALSE, in_place = FALSE)
```

## Arguments

- `reverse`: bool if TRUE, signals series is Descendingly sorted, otherwise Ascendingly.
- `in_place`: if TRUE, will set flag mutably and return NULL. Remember to use pl$set_polars_options(strictly_immutable = FALSE) otherwise an error will be thrown. If FALSE will return a cloned Series with set_flag which in the very most cases should be just fine.

## Returns

Series invisible

Set sorted

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>s</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>set_sorted</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s</span><span class='op'>$</span><span class='va'>flags</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $SORTED_ASC</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $SORTED_DESC</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>