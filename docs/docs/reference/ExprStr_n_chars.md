# n_chars

## Format

function

## Returns

Expr of u32 n_chars

Get length of the strings as UInt32 (as number of chars).

## Details

If you know that you are working with ASCII text, `lengths` will be equivalent, and faster (returns length in terms of the number of bytes).

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  s <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"Café"</span>, <span class='cn'>NA</span>, <span class='st'>"345"</span>, <span class='st'>"æøå"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"s"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"s"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>lengths</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"lengths"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"s"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>n_chars</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"n_chars"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────────┬─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ s    ┆ lengths ┆ n_chars │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---     ┆ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str  ┆ u32     ┆ u32     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════════╪═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Café ┆ 5       ┆ 4       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null    ┆ null    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 345  ┆ 3       ┆ 3       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ æøå  ┆ 6       ┆ 3       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────────┴─────────┘</span>
 </code></pre>