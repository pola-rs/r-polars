# Offset By

## Format

function

## Arguments

- `by`: optional string encoding duration see details.

## Returns

Date/Datetime expr

Offset this date by a relative time offset. This differs from `pl$col("foo_datetime_tu") + value_tu` in that it can take months and leap years into account. Note that only a single minus sign is allowed in the `by` string, as the first character.

## Details

The `by` are created with the the following string language:

 * 1ns # 1 nanosecond
 * 1us # 1 microsecond
 * 1ms # 1 millisecond
 * 1s # 1 second
 * 1m # 1 minute
 * 1h # 1 hour
 * 1d # 1 day
 * 1w # 1 calendar week
 * 1mo # 1 calendar month
 * 1y # 1 calendar year
 * 1i # 1 index count

These strings can be combined:

 * 3d12h4m25s # 3 days, 12 hours, 4 minutes, and 25 seconds

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  dates <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2000-1-1"</span><span class='op'>)</span>,<span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2005-1-1"</span><span class='op'>)</span>, <span class='st'>"1y"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"dates"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>offset_by</span><span class='op'>(</span><span class='st'>"1y"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"date_plus_1y"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"dates"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>offset_by</span><span class='op'>(</span><span class='st'>"-1y2mo"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"date_min"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (6, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────┬─────────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date_plus_1y        ┆ date_min            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                 ┆ ---                 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[μs]        ┆ datetime[μs]        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════╪═════════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-01-01 00:00:00 ┆ 1998-11-01 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2002-01-01 00:00:00 ┆ 1999-11-01 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2003-01-01 00:00:00 ┆ 2000-11-01 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2004-01-01 00:00:00 ┆ 2001-11-01 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2005-01-01 00:00:00 ┆ 2002-11-01 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2006-01-01 00:00:00 ┆ 2003-11-01 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────┴─────────────────────┘</span>
 </code></pre>