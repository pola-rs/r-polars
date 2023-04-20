# Has multiple outputs

## Returns

Bool

Whether this expression expands into multiple expressions.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>has_multiple_outputs</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"some_colname"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>has_multiple_outputs</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
 </code></pre>