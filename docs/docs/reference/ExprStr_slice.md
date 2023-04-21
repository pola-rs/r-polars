# slice

## Arguments

- `pattern`: Into  , regex pattern
- `value`: Into  replcacement
- `literal`: bool, treat pattern as a literal string.

## Returns

Expr: Series of dtype Utf8.

Create subslices of the string values of a Utf8 Series.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>s <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"pear"</span>, <span class='cn'>NA</span>, <span class='st'>"papaya"</span>, <span class='st'>"dragonfruit"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>   <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"s"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>slice</span><span class='op'>(</span><span class='op'>-</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"s_sliced"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (4, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────┬──────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ s           ┆ s_sliced │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---         ┆ ---      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str         ┆ str      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════╪══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ pear        ┆ ear      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null        ┆ null     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ papaya      ┆ aya      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ dragonfruit ┆ uit      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────┴──────────┘</span>
 </code></pre>