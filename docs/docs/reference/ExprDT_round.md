# Round datetime

*Source: [R/expr__datetime.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__datetime.R)*

## Format

function

## Arguments

- `every`: string encoding duration see details.
- `ofset`: optional string encoding duration see details.

## Returns

Date/Datetime expr

Divide the date/datetime range into buckets. Each date/datetime in the first half of the interval is mapped to the start of its bucket. Each date/datetime in the second half of the interval is mapped to the end of its bucket.

## Details

The `every` and `offset` argument are created with the the following string language:

 * 1ns # 1 nanosecond
 * 1us # 1 microsecond
 * 1ms # 1 millisecond
 * 1s # 1 second
 * 1m # 1 minute
 * 1h # 1 hour
 * 1d # 1 day
 * 1w # 1 calendar week
 * 1mo # 1 calendar month
 * 1y # 1 calendar year These strings can be combined:
   
    * 3d12h4m25s # 3 days, 12 hours, 4 minutes, and 25 seconds

This functionality is currently experimental and may change without it being considered a breaking change.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>t1</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"3040-01-01"</span>,tz <span class='op'>=</span> <span class='st'>"GMT"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>t2</span> <span class='op'>=</span> <span class='va'>t1</span> <span class='op'>+</span> <span class='fu'><a href='https://rdrr.io/r/base/difftime.html'>as.difftime</a></span><span class='op'>(</span><span class='fl'>25</span>,units <span class='op'>=</span> <span class='st'>"secs"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span><span class='va'>t1</span>, <span class='va'>t2</span>, interval <span class='op'>=</span> <span class='st'>"2s"</span>, time_unit <span class='op'>=</span> <span class='st'>"ms"</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#use a dt namespace function</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>datetime <span class='op'>=</span> <span class='va'>s</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"datetime"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>truncate</span><span class='op'>(</span><span class='st'>"4s"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"truncated_4s"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"datetime"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>truncate</span><span class='op'>(</span><span class='st'>"4s"</span>,<span class='fu'><a href='https://rdrr.io/r/stats/offset.html'>offset</a></span><span class='op'>(</span><span class='st'>"3s"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"truncated_4s_offset_2s"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (13, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────┬─────────────────────┬────────────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime            ┆ truncated_4s        ┆ truncated_4s_offset_2s │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                 ┆ ---                 ┆ ---                    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[ms]        ┆ datetime[ms]        ┆ datetime[ms]           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════╪═════════════════════╪════════════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3040-01-01 00:00:00 ┆ 3040-01-01 00:00:00 ┆ 3040-01-01 00:00:03    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3040-01-01 00:00:02 ┆ 3040-01-01 00:00:00 ┆ 3040-01-01 00:00:03    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3040-01-01 00:00:04 ┆ 3040-01-01 00:00:04 ┆ 3040-01-01 00:00:07    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3040-01-01 00:00:06 ┆ 3040-01-01 00:00:04 ┆ 3040-01-01 00:00:07    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...                 ┆ ...                 ┆ ...                    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3040-01-01 00:00:18 ┆ 3040-01-01 00:00:16 ┆ 3040-01-01 00:00:19    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3040-01-01 00:00:20 ┆ 3040-01-01 00:00:20 ┆ 3040-01-01 00:00:23    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3040-01-01 00:00:22 ┆ 3040-01-01 00:00:20 ┆ 3040-01-01 00:00:23    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3040-01-01 00:00:24 ┆ 3040-01-01 00:00:24 ┆ 3040-01-01 00:00:27    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────┴─────────────────────┴────────────────────────┘</span>
 </code></pre>