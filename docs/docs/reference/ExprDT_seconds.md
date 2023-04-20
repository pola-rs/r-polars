# Seconds

## Format

function

## Returns

Expr of i64

Extract the seconds from a Duration type.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>date <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span></span></span>
<span class='r-in'><span>    low <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2020-1-1"</span>, tz <span class='op'>=</span> <span class='st'>"GMT"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    high <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2020-1-1 00:04:00"</span>, tz <span class='op'>=</span> <span class='st'>"GMT"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    interval <span class='op'>=</span> <span class='st'>"1m"</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>diff</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>seconds</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"seconds_diff"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────┬──────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date                ┆ seconds_diff │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                 ┆ ---          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[μs]        ┆ i64          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════╪══════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-01 00:00:00 ┆ null         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-01 00:01:00 ┆ 60           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-01 00:02:00 ┆ 60           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-01 00:03:00 ┆ 60           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-01-01 00:04:00 ┆ 60           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────┴──────────────┘</span>
 </code></pre>