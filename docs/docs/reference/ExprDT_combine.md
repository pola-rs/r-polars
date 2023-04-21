# Combine Data and Time

*Source: [R/expr__datetime.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__datetime.R)*

## Format

function

## Arguments

- `tm`: Expr or numeric or PTime, the number of epoch since or before(if negative) the Date or tm is an Expr e.g. a column of DataType 'Time' or something into an Expr.
- `tu`: time unit of epochs, default is "us", if tm is a PTime, then tz passed via PTime.

## Returns

Date/Datetime expr

Create a naive Datetime from an existing Date/Datetime expression and a Time. Each date/datetime in the first half of the interval is mapped to the start of its bucket. Each date/datetime in the second half of the interval is mapped to the end of its bucket.

## Details

The `tu` allows the following time time units the following string language:

 * 1ns # 1 nanosecond
 * 1us # 1 microsecond
 * 1ms # 1 millisecond

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#Using pl$PTime</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2021-01-01"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>combine</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>PTime</span><span class='op'>(</span><span class='st'>"02:34:12"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [datetime[ns]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2021-01-01 02:34:12</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2021-01-01"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>combine</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>PTime</span><span class='op'>(</span><span class='fl'>3600</span> <span class='op'>*</span> <span class='fl'>1.5</span>, tu<span class='op'>=</span><span class='st'>"s"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [datetime[ns]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2021-01-01 01:30:00</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2021-01-01"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>combine</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>PTime</span><span class='op'>(</span><span class='fl'>3600</span> <span class='op'>*</span> <span class='fl'>1.5E6</span> <span class='op'>+</span> <span class='fl'>123</span>, tu<span class='op'>=</span><span class='st'>"us"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [datetime[ns]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2021-01-01 01:30:00.000123</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#pass double and set tu manually</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2021-01-01"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>combine</span><span class='op'>(</span><span class='fl'>3600</span> <span class='op'>*</span> <span class='fl'>1.5E6</span> <span class='op'>+</span> <span class='fl'>123</span>, tu<span class='op'>=</span><span class='st'>"us"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [datetime[μs]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2021-01-01 01:30:00.000123</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#if needed to convert back to R it is more intuitive to set a specific time zone</span></span></span>
<span class='r-in'><span><span class='va'>expr</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2021-01-01"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>combine</span><span class='op'>(</span><span class='fl'>3600</span> <span class='op'>*</span> <span class='fl'>1.5E6</span> <span class='op'>+</span> <span class='fl'>123</span>, tu<span class='op'>=</span><span class='st'>"us"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>expr</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Datetime</span><span class='op'>(</span>tu <span class='op'>=</span> <span class='st'>"us"</span>, tz <span class='op'>=</span> <span class='st'>"GMT"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "2021-01-01 01:30:00 GMT"</span>
 </code></pre>