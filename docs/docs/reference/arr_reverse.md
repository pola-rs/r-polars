# Reverse list

## Format

function

## Returns

Expr

Reverse the arrays in the list.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  values <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fl'>3</span><span class='op'>:</span><span class='fl'>1</span>, <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>9L</span>, <span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"values"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>reverse</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ values    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list[i32] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [1, 2, 3] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [2, 1, 9] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────┘</span>
 </code></pre>