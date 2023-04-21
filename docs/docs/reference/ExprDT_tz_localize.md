# Localize time zone

## Format

function

## Arguments

- `tz`: string of time zone (no NULL allowed) see allowed timezone in base::OlsonNames()

## Returns

Expr of i64

Localize tz-naive Datetime Series to tz-aware Datetime Series. This method takes a naive Datetime Series and makes this time zone aware. It does not move the time to another time zone.

## Details

In R as modifying tzone attribute manually but takes into account summertime. See unittest "dt$convert_time_zone dt$tz_localize" for a more detailed comparison to base R.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  date <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span>low <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2001-3-1"</span><span class='op'>)</span>, high <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2001-7-1"</span><span class='op'>)</span>, interval <span class='op'>=</span> <span class='st'>"1mo"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>df</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>replace_time_zone</span><span class='op'>(</span><span class='st'>"Europe/Amsterdam"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>convert_time_zone</span><span class='op'>(</span><span class='st'>"Europe/London"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"london_timezone"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>tz_localize</span><span class='op'>(</span><span class='st'>"Europe/London"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"tz_loc_london"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df2</span> <span class='op'>=</span> <span class='va'>df</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"london_timezone"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>replace_time_zone</span><span class='op'>(</span><span class='st'>"Europe/Amsterdam"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"cast London_to_Amsterdam"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"london_timezone"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>convert_time_zone</span><span class='op'>(</span><span class='st'>"Europe/Amsterdam"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"with London_to_Amsterdam"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"london_timezone"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>convert_time_zone</span><span class='op'>(</span><span class='st'>"Europe/Amsterdam"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>replace_time_zone</span><span class='op'>(</span><span class='cn'>NULL</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"strip tz from with-'Europe/Amsterdam'"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df2</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 6)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────────┬────────────────┬────────────────┬───────────────┬───────────────┬───────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date           ┆ london_timezon ┆ tz_loc_london  ┆ cast London_t ┆ with London_t ┆ strip tz from │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---            ┆ e              ┆ ---            ┆ o_Amsterdam   ┆ o_Amsterdam   ┆ with-'Europe/ │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[μs]   ┆ ---            ┆ datetime[μs,   ┆ ---           ┆ ---           ┆ Amste...      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │                ┆ datetime[μs,   ┆ Europe/London] ┆ datetime[μs,  ┆ datetime[μs,  ┆ ---           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │                ┆ Europe/London] ┆                ┆ Europe/Amster ┆ Europe/Amster ┆ datetime[μs]  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │                ┆                ┆                ┆ dam]          ┆ dam]          ┆               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════════╪════════════════╪════════════════╪═══════════════╪═══════════════╪═══════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-03-01     ┆ 2001-02-28     ┆ 2001-03-01     ┆ 2001-02-28    ┆ 2001-03-01    ┆ 2001-03-01    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 00:00:00       ┆ 23:00:00 GMT   ┆ 00:00:00 GMT   ┆ 23:00:00 CET  ┆ 00:00:00 CET  ┆ 00:00:00      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-04-01     ┆ 2001-03-31     ┆ 2001-04-01     ┆ 2001-03-31    ┆ 2001-04-01    ┆ 2001-04-01    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 00:00:00       ┆ 23:00:00 BST   ┆ 00:00:00 BST   ┆ 23:00:00 CEST ┆ 00:00:00 CEST ┆ 00:00:00      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-05-01     ┆ 2001-04-30     ┆ 2001-05-01     ┆ 2001-04-30    ┆ 2001-05-01    ┆ 2001-05-01    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 00:00:00       ┆ 23:00:00 BST   ┆ 00:00:00 BST   ┆ 23:00:00 CEST ┆ 00:00:00 CEST ┆ 00:00:00      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-06-01     ┆ 2001-05-31     ┆ 2001-06-01     ┆ 2001-05-31    ┆ 2001-06-01    ┆ 2001-06-01    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 00:00:00       ┆ 23:00:00 BST   ┆ 00:00:00 BST   ┆ 23:00:00 CEST ┆ 00:00:00 CEST ┆ 00:00:00      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-07-01     ┆ 2001-06-30     ┆ 2001-07-01     ┆ 2001-06-30    ┆ 2001-07-01    ┆ 2001-07-01    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 00:00:00       ┆ 23:00:00 BST   ┆ 00:00:00 BST   ┆ 23:00:00 CEST ┆ 00:00:00 CEST ┆ 00:00:00      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────────┴────────────────┴────────────────┴───────────────┴───────────────┴───────────────┘</span>
 </code></pre>