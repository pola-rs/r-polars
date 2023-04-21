# Day

## Format

function

## Returns

Expr of day as UInt32

Extract day from underlying Date representation. Applies to Date and Datetime columns. Returns the day of month starting from 1. The return value ranges from 1 to 31. (The last day of month differs by months.)

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  date <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span></span></span>
<span class='r-in'><span>    <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2020-12-25"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2021-1-05"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    interval <span class='op'>=</span> <span class='st'>"1d"</span>,</span></span>
<span class='r-in'><span>    time_zone <span class='op'>=</span> <span class='st'>"GMT"</span></span></span>
<span class='r-in'><span>  <span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>day</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"day"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (12, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────────┬─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date                    ┆ day │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                     ┆ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[μs, GMT]       ┆ u32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════════╪═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-12-25 00:00:00 GMT ┆ 25  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-12-26 00:00:00 GMT ┆ 26  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-12-27 00:00:00 GMT ┆ 27  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-12-28 00:00:00 GMT ┆ 28  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...                     ┆ ... │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2021-01-02 00:00:00 GMT ┆ 2   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2021-01-03 00:00:00 GMT ┆ 3   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2021-01-04 00:00:00 GMT ┆ 4   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2021-01-05 00:00:00 GMT ┆ 5   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────────┴─────┘</span>
 </code></pre>