# cast_time_unit

*Source: [R/expr__datetime.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__datetime.R)*

## Format

function

## Arguments

- `tu`: string option either 'ns', 'us', or 'ms'

## Returns

Expr of i64

Cast the underlying data to another time unit. This may lose precision. The corresponding global timepoint will stay unchanged +/- precision.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  date <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span>low <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2001-1-1"</span><span class='op'>)</span>, high <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2001-1-3"</span><span class='op'>)</span>, interval <span class='op'>=</span> <span class='st'>"1d"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>cast_time_unit</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"cast_time_unit_ns"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>cast_time_unit</span><span class='op'>(</span>tu<span class='op'>=</span><span class='st'>"ms"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"cast_time_unit_ms"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────┬─────────────────────┬─────────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date                ┆ cast_time_unit_ns   ┆ cast_time_unit_ms   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                 ┆ ---                 ┆ ---                 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[μs]        ┆ datetime[ns]        ┆ datetime[ms]        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════╪═════════════════════╪═════════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-01-01 00:00:00 ┆ 2001-01-01 00:00:00 ┆ 2001-01-01 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-01-02 00:00:00 ┆ 2001-01-02 00:00:00 ┆ 2001-01-02 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-01-03 00:00:00 ┆ 2001-01-03 00:00:00 ┆ 2001-01-03 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────┴─────────────────────┴─────────────────────┘</span>
 </code></pre>