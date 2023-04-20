# strptime

## Arguments

- `datatype`: a temporal data type either pl$Date, pl$Time or pl$Datetime
- `fmt`: fmt string for parsenig see see details here https://docs.rs/chrono/latest/chrono/format/strftime/index.html#fn6 Notice time_zone %Z is not supported and will just ignore timezones. Numeric tz like %z, %:z .... are supported.
- `strict`: bool, if true raise error if a single string cannot be parsed, else produce a polars `null`.
- `exact`: bool , If True, require an exact format match. If False, allow the format to match anywhere in the target string.
- `cache`: Use a cache of unique, converted dates to apply the datetime conversion.
- `tz_aware`: bool, Parse timezone aware datetimes. This may be automatically toggled by the ‘fmt’ given.
- `utc`: bool Parse timezone aware datetimes as UTC. This may be useful if you have data with mixed offsets.

## Returns

Expr of a Data, Datetime or Time Series

Parse a Series of dtype Utf8 to a Date/Datetime Series.

## Details

Notes When parsing a Datetime the column precision will be inferred from the format string, if given, eg: “%F %T%.3f” => Datetime(“ms”). If no fractional second component is found then the default is “us”.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>s</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>        <span class='st'>"2021-04-22"</span>,</span></span>
<span class='r-in'><span>        <span class='st'>"2022-01-04 00:00:00"</span>,</span></span>
<span class='r-in'><span>        <span class='st'>"01/31/22"</span>,</span></span>
<span class='r-in'><span>        <span class='st'>"Sun Jul  8 00:34:60 2001"</span></span></span>
<span class='r-in'><span>  <span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='st'>"date"</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='co'>#' #join multiple passes with different fmt</span></span></span>
<span class='r-in'><span><span class='va'>s</span><span class='op'>$</span><span class='fu'>to_frame</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>    <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>strptime</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Date</span>, <span class='st'>"%F"</span>, strict<span class='op'>=</span><span class='cn'>FALSE</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>fill_null</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>strptime</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Date</span>, <span class='st'>"%F %T"</span>, strict<span class='op'>=</span><span class='cn'>FALSE</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>fill_null</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>strptime</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Date</span>, <span class='st'>"%D"</span>, strict<span class='op'>=</span><span class='cn'>FALSE</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>fill_null</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>strptime</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Date</span>, <span class='st'>"%c"</span>, strict<span class='op'>=</span><span class='cn'>FALSE</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2021-04-22 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2022-01-04 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2022-01-31 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2001-07-08 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>txt_datetimes</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='st'>"2023-01-01 11:22:33 -0100"</span>,</span></span>
<span class='r-in'><span>  <span class='st'>"2023-01-01 11:22:33 +0300"</span>,</span></span>
<span class='r-in'><span>  <span class='st'>"invalid time"</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='va'>txt_datetimes</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>strptime</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Datetime</span><span class='op'>(</span><span class='st'>"ns"</span><span class='op'>)</span>,fmt <span class='op'>=</span> <span class='st'>"%Y-%m-%d %H:%M:%S %z"</span>, strict <span class='op'>=</span> <span class='cn'>FALSE</span>,</span></span>
<span class='r-in'><span>  tz_aware <span class='op'>=</span> <span class='cn'>TRUE</span>, utc <span class='op'>=</span><span class='cn'>TRUE</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (3,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [datetime[ns, UTC]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2023-01-01 12:22:33 UTC</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2023-01-01 08:22:33 UTC</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	null</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>