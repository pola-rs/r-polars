# replace

## Arguments

- `pattern`: Into  , regex pattern
- `value`: Into  replcacement
- `literal`: bool, Treat pattern as a literal string.

## Returns

Expr of Utf8 Series

Replace first matching regex/literal substring with a new string value.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>id <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>, <span class='fl'>2</span><span class='op'>)</span>, text <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"123abc"</span>, <span class='st'>"abc456"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>   <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"text"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>replace</span><span class='op'>(</span><span class='st'>r"{abc\b}"</span>, <span class='st'>"ABC"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ id  ┆ text   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 ┆ str    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0 ┆ 123ABC │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2.0 ┆ abc456 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴────────┘</span>
 </code></pre>