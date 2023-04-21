# Root Name

## Returns

R charvec of root names.

Get a vector with the root column name

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>e</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"alice"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"bob"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>e</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>root_names</span><span class='op'>(</span><span class='op'>)</span> <span class='op'>==</span> <span class='st'>"alice"</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span><span class='va'>e</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>output_name</span><span class='op'>(</span><span class='op'>)</span> <span class='op'>==</span> <span class='st'>"bob"</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span><span class='va'>e</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>undo_aliases</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>output_name</span><span class='op'>(</span><span class='op'>)</span> <span class='op'>==</span> <span class='st'>"alice"</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
 </code></pre>