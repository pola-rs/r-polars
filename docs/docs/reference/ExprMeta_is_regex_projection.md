# Is regex projecion.

*Source: [R/expr__meta.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__meta.R)*

## Returns

Bool

Whether this expression expands to columns that match a regex pattern.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"^Sepal.*$"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>is_regex_projection</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Sepal.Length"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>is_regex_projection</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
 </code></pre>