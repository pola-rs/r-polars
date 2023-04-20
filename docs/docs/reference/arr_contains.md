# Sublists contains

## Format

function

## Arguments

- `item`: any into Expr/literal

## Returns

Expr of a boolean mask

Check if sublists contain the given item.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fl'>3</span><span class='op'>:</span><span class='fl'>1</span>, <span class='cn'>NULL</span>, <span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span> <span class='co'>#NULL or integer() or list()</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>contains</span><span class='op'>(</span><span class='fl'>1L</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bool  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┘</span>
 </code></pre>