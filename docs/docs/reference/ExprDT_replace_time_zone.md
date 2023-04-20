# replace_time_zone

## Format

function

## Arguments

- `tz`: Null or string time zone from base::OlsonNames()

## Returns

Expr of i64

Cast time zone for a Series of type Datetime. Different from `convert_time_zone`, this will also modify the underlying timestamp. Use to correct a wrong time zone annotation. This will change the corresponding global timepoint.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  date <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span>low <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2001-3-1"</span><span class='op'>)</span>, high <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2001-7-1"</span><span class='op'>)</span>, interval <span class='op'>=</span> <span class='st'>"1mo"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>df</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>replace_time_zone</span><span class='op'>(</span><span class='st'>"Europe/Amsterdam"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>convert_time_zone</span><span class='op'>(</span><span class='st'>"Europe/London"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"london_timezone"</span><span class='op'>)</span></span></span>
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
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 5)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬─────────────────┬─────────────────────┬─────────────────────┬─────────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date         ┆ london_timezone ┆ cast                ┆ with                ┆ strip tz from with- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---             ┆ London_to_Amsterdam ┆ London_to_Amsterdam ┆ 'Europe/Amste...    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[μs] ┆ datetime[μs,    ┆ ---                 ┆ ---                 ┆ ---                 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │              ┆ Europe/London]  ┆ datetime[μs,        ┆ datetime[μs,        ┆ datetime[μs]        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │              ┆                 ┆ Europe/Amsterdam]   ┆ Europe/Amsterdam]   ┆                     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪═════════════════╪═════════════════════╪═════════════════════╪═════════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-03-01   ┆ 2001-02-28      ┆ 2001-02-28 23:00:00 ┆ 2001-03-01 00:00:00 ┆ 2001-03-01 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 00:00:00     ┆ 23:00:00 GMT    ┆ CET                 ┆ CET                 ┆                     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-04-01   ┆ 2001-03-31      ┆ 2001-03-31 23:00:00 ┆ 2001-04-01 00:00:00 ┆ 2001-04-01 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 00:00:00     ┆ 23:00:00 BST    ┆ CEST                ┆ CEST                ┆                     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-05-01   ┆ 2001-04-30      ┆ 2001-04-30 23:00:00 ┆ 2001-05-01 00:00:00 ┆ 2001-05-01 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 00:00:00     ┆ 23:00:00 BST    ┆ CEST                ┆ CEST                ┆                     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-06-01   ┆ 2001-05-31      ┆ 2001-05-31 23:00:00 ┆ 2001-06-01 00:00:00 ┆ 2001-06-01 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 00:00:00     ┆ 23:00:00 BST    ┆ CEST                ┆ CEST                ┆                     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-07-01   ┆ 2001-06-30      ┆ 2001-06-30 23:00:00 ┆ 2001-07-01 00:00:00 ┆ 2001-07-01 00:00:00 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 00:00:00     ┆ 23:00:00 BST    ┆ CEST                ┆ CEST                ┆                     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴─────────────────┴─────────────────────┴─────────────────────┴─────────────────────┘</span>
 </code></pre>