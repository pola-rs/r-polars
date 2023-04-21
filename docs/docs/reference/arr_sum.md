# Sum lists

## Format

function

## Returns

Expr

Sum all the lists in the array.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>values <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fl'>1L</span>,<span class='fl'>2</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"values"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ values │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────┘</span>
 </code></pre>