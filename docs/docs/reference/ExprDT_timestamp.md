# timestamp

## Format

function

## Arguments

- `tu`: string option either 'ns', 'us', or 'ms'

## Returns

Expr of i64

Return a timestamp in the given time unit.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  date <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span>low <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2001-1-1"</span><span class='op'>)</span>, high <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2001-1-3"</span><span class='op'>)</span>, interval <span class='op'>=</span> <span class='st'>"1d"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>timestamp</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"timestamp_ns"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>timestamp</span><span class='op'>(</span>tu<span class='op'>=</span><span class='st'>"ms"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"timestamp_ms"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (3, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────┬────────────────────┬──────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date                ┆ timestamp_ns       ┆ timestamp_ms │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                 ┆ ---                ┆ ---          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[μs]        ┆ i64                ┆ i64          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════╪════════════════════╪══════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-01-01 00:00:00 ┆ 978307200000000000 ┆ 978307200000 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-01-02 00:00:00 ┆ 978393600000000000 ┆ 978393600000 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-01-03 00:00:00 ┆ 978480000000000000 ┆ 978480000000 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────┴────────────────────┴──────────────┘</span>
 </code></pre>