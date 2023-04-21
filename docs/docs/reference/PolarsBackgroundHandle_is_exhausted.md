# PolarsBackgroundHandle

*Source: [R/lazyframe__background.R](https://github.com/pola-rs/r-polars/tree/main/R/lazyframe__background.R)*

```r
PolarsBackgroundHandle_is_exhausted()
```

## Returns

Bool

PolarsBackgroundHandle

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>lazy_df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>[</span>,<span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>]</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>first</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>handle</span> <span class='op'>=</span> <span class='va'>lazy_df</span><span class='op'>$</span><span class='fu'>collect_background</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>handle</span><span class='op'>$</span><span class='fu'>is_exhausted</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>handle</span><span class='op'>$</span><span class='fu'>join</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>handle</span><span class='op'>$</span><span class='fu'>is_exhausted</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
 </code></pre>