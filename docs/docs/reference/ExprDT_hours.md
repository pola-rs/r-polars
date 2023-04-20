# Hours

## Format

function

## Returns

Expr of i64

Extract the hours from a Duration type.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  date <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span>low <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2020-1-1"</span><span class='op'>)</span>, high <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2020-1-4"</span><span class='op'>)</span>, interval <span class='op'>=</span> <span class='st'>"1d"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>diff</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>hours</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"hours_diff"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────┬────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date                ┆ hours_diff │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                 ┆ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[μs]        ┆ i64        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════╪════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-01 00:00:00 ┆ null       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-02 00:00:00 ┆ 24         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-03 00:00:00 ┆ 24         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-04 00:00:00 ┆ 24         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────┴────────────┘</span>
 </code></pre>