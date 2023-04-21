# nanoseconds

## Format

function

## Returns

Expr of i64

Extract the nanoseconds from a Duration type.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>date <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span></span></span>
<span class='r-in'><span>    low <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2020-1-1"</span>, tz <span class='op'>=</span> <span class='st'>"GMT"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    high <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2020-1-1 00:00:01"</span>, tz <span class='op'>=</span> <span class='st'>"GMT"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    interval <span class='op'>=</span> <span class='st'>"1ms"</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>diff</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>nanoseconds</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"seconds_diff"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1001, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────────┬──────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date                    ┆ seconds_diff │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                     ┆ ---          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[μs]            ┆ i64          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════════╪══════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-01 00:00:00     ┆ null         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-01 00:00:00.001 ┆ 1000000      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-01 00:00:00.002 ┆ 1000000      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-01 00:00:00.003 ┆ 1000000      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...                     ┆ ...          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-01 00:00:00.997 ┆ 1000000      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-01 00:00:00.998 ┆ 1000000      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-01 00:00:00.999 ┆ 1000000      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-01 00:00:01     ┆ 1000000      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────────┴──────────────┘</span>
 </code></pre>