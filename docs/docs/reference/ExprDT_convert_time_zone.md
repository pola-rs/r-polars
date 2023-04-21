# With Time Zone

## Format

function

## Arguments

- `tz`: String time zone from base::OlsonNames()

## Returns

Expr of i64

Set time zone for a Series of type Datetime. Use to change time zone annotation, but keep the corresponding global timepoint.

## Details

corresponds to in R manually modifying the tzone attribute of POSIXt objects

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  date <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span>low <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2001-3-1"</span><span class='op'>)</span>, high <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2001-5-1"</span><span class='op'>)</span>, interval <span class='op'>=</span> <span class='st'>"1mo"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>replace_time_zone</span><span class='op'>(</span><span class='st'>"Europe/Amsterdam"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>convert_time_zone</span><span class='op'>(</span><span class='st'>"Europe/London"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"London_with"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>tz_localize</span><span class='op'>(</span><span class='st'>"Europe/London"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"London_localize"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────┬─────────────────────────────┬─────────────────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date                ┆ London_with                 ┆ London_localize             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                 ┆ ---                         ┆ ---                         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[μs]        ┆ datetime[μs, Europe/London] ┆ datetime[μs, Europe/London] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════╪═════════════════════════════╪═════════════════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-03-01 00:00:00 ┆ 2001-02-28 23:00:00 GMT     ┆ 2001-03-01 00:00:00 GMT     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-04-01 00:00:00 ┆ 2001-03-31 23:00:00 BST     ┆ 2001-04-01 00:00:00 BST     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-05-01 00:00:00 ┆ 2001-04-30 23:00:00 BST     ┆ 2001-05-01 00:00:00 BST     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────┴─────────────────────────────┴─────────────────────────────┘</span>
 </code></pre>