# an element in 'eval'-expr

## Returns

Expr

Alias for an element in evaluated in an `eval` expression.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cumulative_eval</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>element</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>first</span><span class='op'>(</span><span class='op'>)</span><span class='op'>-</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>element</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>last</span><span class='op'>(</span><span class='op'>)</span> <span class='op'>**</span> <span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1]   0  -3  -8 -15 -24</span>
 </code></pre>