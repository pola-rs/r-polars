# with_time_unit

## Format

function

## Arguments

- `tu`: string option either 'ns', 'us', or 'ms'

## Returns

Expr of i64

Set time unit of a Series of dtype Datetime or Duration. This does not modify underlying data, and should be used to fix an incorrect time unit. The corresponding global timepoint will change.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  date <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span>low <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2001-1-1"</span><span class='op'>)</span>, high <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2001-1-3"</span><span class='op'>)</span>, interval <span class='op'>=</span> <span class='st'>"1d"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>with_time_unit</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"with_time_unit_ns"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>with_time_unit</span><span class='op'>(</span>tu<span class='op'>=</span><span class='st'>"ms"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"with_time_unit_ms"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (3, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────┬─────────────────────────┬───────────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date                ┆ with_time_unit_ns       ┆ with_time_unit_ms     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                 ┆ ---                     ┆ ---                   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[μs]        ┆ datetime[ns]            ┆ datetime[ms]          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════╪═════════════════════════╪═══════════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-01-01 00:00:00 ┆ 1970-01-12 07:45:07.200 ┆ +32971-04-28 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-01-02 00:00:00 ┆ 1970-01-12 07:46:33.600 ┆ +32974-01-22 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-01-03 00:00:00 ┆ 1970-01-12 07:48:00     ┆ +32976-10-18 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────┴─────────────────────────┴───────────────────────┘</span>
 </code></pre>