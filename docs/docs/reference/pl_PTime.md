# Store Time in R

*Source: [R/PTime.R](https://github.com/pola-rs/r-polars/tree/main/R/PTime.R)*

## Arguments

- `x`: an integer or double vector of n epochs since midnight OR a char vector of char times passed to as.POSIXct converted to seconds.
- `tu`: timeunit either "s","ms","us","ns"
- `fmt`: a format string passed to as.POSIXct format via ...

## Returns

a PTime vector either double or integer, with class "PTime" and attribute "tu" being either "s","ms","us" or "ns"

Store Time in R

## Details

PTime should probably be replaced with package nanotime or similar.

base R is missing encoding of Time since midnight "s" "ms", "us" and "ns". The latter "ns" is the standard for the polars Time type.

Use PTime to convert R doubles and integers and use as input to polars functions which needs a time.

Loosely inspired by data.table::ITime which is i32 only. PTime must support polars native timeunit is nanoseconds. The R double(float64) can imitate a i64 ns with full precision within the full range of 24 hours.

PTime does not have a time zone and always prints the time as is no matter local machine time zone.

An essential difference between R and polars is R prints POSIXct/lt without a timezone in local time. Polars prints Datetime without a timezone label as is (GMT). For POSIXct/lt taged with a timexone(tzone) and Datetime with a timezone(tz) the behavior is the same conversion is intuitive.

It appears behavior of R timezones is subject to change a bit in R 4.3.0, see polars unit test test-expr_datetime.R/"pl$date_range Date lazy/eager".

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#make PTime in all time units</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>PTime</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='op'>(</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>*</span><span class='fl'>3600</span><span class='op'>*</span><span class='fl'>24</span><span class='op'>*</span><span class='fl'>1E0</span>, tu <span class='op'>=</span> <span class='st'>"s"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> PTime [ double ]: number of epochs [ s ] since midnight</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "15:33:05 val: 55985" "00:01:10 val: 70"    "20:05:31 val: 72331" "04:48:10 val: 17290" "04:54:24 val: 17664"</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>PTime</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='op'>(</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>*</span><span class='fl'>3600</span><span class='op'>*</span><span class='fl'>24</span><span class='op'>*</span><span class='fl'>1E3</span>, tu <span class='op'>=</span> <span class='st'>"ms"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> PTime [ double ]: number of epochs [ ms ] since midnight</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "02:05:17:738ms val: 7517738"  "11:28:33:197ms val: 41313197" "10:25:47:991ms val: 37547991" "17:49:40:318ms val: 64180318"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [5] "17:25:24:491ms val: 62724491"</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>PTime</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='op'>(</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>*</span><span class='fl'>3600</span><span class='op'>*</span><span class='fl'>24</span><span class='op'>*</span><span class='fl'>1E6</span>, tu <span class='op'>=</span> <span class='st'>"us"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> PTime [ double ]: number of epochs [ us ] since midnight</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "17:33:31:997_227us val: 63211997227" "18:47:28:183_022us val: 67648183022" "11:43:51:610_804us val: 42231610804"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [4] "20:24:44:574_399us val: 73484574399" "01:39:31:990_983us val: 5971990983" </span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>PTime</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='op'>(</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>*</span><span class='fl'>3600</span><span class='op'>*</span><span class='fl'>24</span><span class='op'>*</span><span class='fl'>1E9</span>, tu <span class='op'>=</span> <span class='st'>"ns"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> PTime [ double ]: number of epochs [ ns ] since midnight</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "19:39:54:338_377_565ns val: 70794338377565" "21:04:11:798_473_298ns val: 75851798473298" "16:14:51:179_843_991ns val: 58491179843991"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [4] "18:35:02:355_766_296ns val: 66902355766296" "12:48:53:771_131_932ns val: 46133771131932"</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>PTime</span><span class='op'>(</span><span class='st'>"23:59:59"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> PTime [ double ]: number of epochs [ s ] since midnight</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "23:59:59 val: 86399"</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>PTime</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='op'>(</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>*</span><span class='fl'>3600</span><span class='op'>*</span><span class='fl'>24</span><span class='op'>*</span><span class='fl'>1E0</span>, tu <span class='op'>=</span> <span class='st'>"s"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (5,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [time]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	18:11:19</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	08:16:05</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	23:30:04</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	13:07:38</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	09:21:58</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>PTime</span><span class='op'>(</span><span class='st'>"23:59:59"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [time]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	23:59:59</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>PTime</span><span class='op'>(</span><span class='st'>"23:59:59"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> PTime [ double ]: number of epochs [ ns ] since midnight</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "23:59:59:000_000_000ns val: 8.6399e+13"</span>
 </code></pre>