# New Expr referring to all columns

## Returns

Boolean literal

Not to mix up with `Expr_object$all()` which is a 'reduce Boolean columns by AND' method.

## Details

last `all()` in example is this Expr method, the first `pl$all()` refers to "all-columns" and is an expression constructor

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>all<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>,<span class='cn'>TRUE</span><span class='op'>)</span>,some<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>,<span class='cn'>FALSE</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ all  ┆ some  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bool ┆ bool  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true ┆ false │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴───────┘</span>
 </code></pre>