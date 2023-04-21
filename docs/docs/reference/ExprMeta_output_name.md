# Output Name

*Source: [R/expr__meta.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__meta.R)*

## Returns

R charvec of output names.

Get the column name that this expression would produce. It might not always be possible to determine the output name as it might depend on the schema of the context. In that case this will raise an error.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>e</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"alice"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"bob"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>e</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>root_names</span><span class='op'>(</span><span class='op'>)</span> <span class='op'>==</span> <span class='st'>"alice"</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span><span class='va'>e</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>output_name</span><span class='op'>(</span><span class='op'>)</span> <span class='op'>==</span> <span class='st'>"bob"</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span><span class='va'>e</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>undo_aliases</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>output_name</span><span class='op'>(</span><span class='op'>)</span> <span class='op'>==</span> <span class='st'>"alice"</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
 </code></pre>