# new date_range

*Source: [R/functions.R](https://github.com/pola-rs/r-polars/tree/main/R/functions.R)*

## Arguments

- `low`: POSIXt or Date preferably with time_zone or double or integer
- `high`: POSIXt or Date preferably with time_zone or double or integer. If high is and interval are missing, then single datetime is constructed.
- `interval`: string pl_duration or R difftime. Can be missing if high is missing also.
- `lazy`: bool, if TRUE return expression
- `closed`: option one of 'both'(default), 'left', 'none' or 'right'
- `name`: name of series
- `time_unit`: option string ("ns" "us" "ms") duration of one int64 value on polars side
- `time_zone`: optional string describing a timezone.

## Returns

a datetime

new date_range

## Details

If param time_zone is not defined the Series will have no time zone.

NOTICE: R POSIXt without defined timezones(tzone/tz), so called naive datetimes, are counter intuitive in R. It is recommended to always set the timezone of low and high. If not output will vary between local machine timezone, R and polars.

In R/r-polars it is perfectly fine to mix timezones of params time_zone, low and high.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'># All in GMT, straight forward, no mental confusion</span></span></span>
<span class='r-in'><span><span class='va'>s_gmt</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2022-01-01"</span>,tz <span class='op'>=</span> <span class='st'>"GMT"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2022-01-02"</span>,tz <span class='op'>=</span> <span class='st'>"GMT"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  interval <span class='op'>=</span> <span class='st'>"6h"</span>, time_unit <span class='op'>=</span> <span class='st'>"ms"</span>, time_zone <span class='op'>=</span> <span class='st'>"GMT"</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s_gmt</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (5,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [datetime[ms, GMT]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 00:00:00 GMT</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 06:00:00 GMT</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 12:00:00 GMT</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 18:00:00 GMT</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-02 00:00:00 GMT</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>s_gmt</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#printed same way in R and polars becuase tagged with a time_zone/tzone</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "2022-01-01 00:00:00 GMT" "2022-01-01 06:00:00 GMT" "2022-01-01 12:00:00 GMT"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [4] "2022-01-01 18:00:00 GMT" "2022-01-02 00:00:00 GMT"</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># polars assumes any input in GMT if time_zone = NULL, set GMT on low high to see same print</span></span></span>
<span class='r-in'><span><span class='va'>s_null</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2022-01-01"</span>,tz <span class='op'>=</span> <span class='st'>"GMT"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2022-01-02"</span>,tz <span class='op'>=</span> <span class='st'>"GMT"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  interval <span class='op'>=</span> <span class='st'>"6h"</span>, time_unit <span class='op'>=</span> <span class='st'>"ms"</span>, time_zone <span class='op'>=</span> <span class='cn'>NULL</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s_null</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#back to R POSIXct. R prints non tzone tagged POSIXct in local timezone.</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "2022-01-01 01:00:00 CET" "2022-01-01 07:00:00 CET" "2022-01-01 13:00:00 CET"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [4] "2022-01-01 19:00:00 CET" "2022-01-02 01:00:00 CET"</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#Any mixing of timezones is fine, just set them all, and it works as expected.</span></span></span>
<span class='r-in'><span><span class='va'>t1</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2022-01-01"</span>, tz <span class='op'>=</span> <span class='st'>"Etc/GMT+2"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>t2</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2022-01-01 08:00:00"</span>, tz <span class='op'>=</span> <span class='st'>"Etc/GMT-2"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s_mix</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span>low <span class='op'>=</span> <span class='va'>t1</span>, high <span class='op'>=</span> <span class='va'>t2</span>, interval <span class='op'>=</span> <span class='st'>"1h"</span>, time_unit <span class='op'>=</span> <span class='st'>"ms"</span>, time_zone <span class='op'>=</span> <span class='st'>"CET"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s_mix</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (5,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [datetime[ms, CET]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 03:00:00 CET</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 04:00:00 CET</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 05:00:00 CET</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 06:00:00 CET</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 07:00:00 CET</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>s_mix</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "2022-01-01 03:00:00 CET" "2022-01-01 04:00:00 CET" "2022-01-01 05:00:00 CET"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [4] "2022-01-01 06:00:00 CET" "2022-01-01 07:00:00 CET"</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#use of ISOdate</span></span></span>
<span class='r-in'><span><span class='va'>t1</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/ISOdatetime.html'>ISOdate</a></span><span class='op'>(</span><span class='fl'>2022</span>,<span class='fl'>1</span>,<span class='fl'>1</span>,<span class='fl'>0</span><span class='op'>)</span> <span class='co'>#preset GMT</span></span></span>
<span class='r-in'><span><span class='va'>t2</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/ISOdatetime.html'>ISOdate</a></span><span class='op'>(</span><span class='fl'>2022</span>,<span class='fl'>1</span>,<span class='fl'>2</span>,<span class='fl'>0</span><span class='op'>)</span> <span class='co'>#preset GMT</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span><span class='va'>t1</span>,<span class='va'>t2</span>,interval <span class='op'>=</span> <span class='st'>"4h"</span>, time_unit <span class='op'>=</span> <span class='st'>"ms"</span>, time_zone <span class='op'>=</span> <span class='st'>"GMT"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (7,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [datetime[ms, GMT]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 00:00:00 GMT</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 04:00:00 GMT</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 08:00:00 GMT</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 12:00:00 GMT</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 16:00:00 GMT</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-01 20:00:00 GMT</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2022-01-02 00:00:00 GMT</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>