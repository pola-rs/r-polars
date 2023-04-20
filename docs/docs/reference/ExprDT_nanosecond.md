# Nanosecond

## Format

function

## Returns

Expr of second as Int64

Extract seconds from underlying Datetime representation. Applies to Datetime columns. Returns the integer second number from 0 to 59, or a floating point number from 0 < 60 if `fractional=True` that includes any milli/micro/nanosecond component.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>date <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/numeric.html'>as.numeric</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2001-1-1"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>*</span><span class='fl'>1E9</span><span class='op'>+</span><span class='fl'>123456789</span>, <span class='co'>#manually convert to us</span></span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/numeric.html'>as.numeric</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2001-1-1 00:00:6"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>*</span><span class='fl'>1E9</span>,</span></span>
<span class='r-in'><span>  interval <span class='op'>=</span> <span class='st'>"1s987654321ns"</span>,</span></span>
<span class='r-in'><span>  time_unit <span class='op'>=</span> <span class='st'>"ns"</span> <span class='co'>#instruct polars input is us, and store as us</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Int64</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"datetime int64"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>nanosecond</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"nanosecond"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (3, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────────┬────────────────────┬────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date                    ┆ datetime int64     ┆ nanosecond │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                     ┆ ---                ┆ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[ns]            ┆ i64                ┆ u32        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════════╪════════════════════╪════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2000-12-31 23:00:00.123 ┆ 978303600123000000 ┆ 123000000  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2000-12-31 23:00:02.110 ┆ 978303602110000000 ┆ 110000000  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2000-12-31 23:00:04.097 ┆ 978303604097000000 ┆ 97000000   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────────┴────────────────────┴────────────┘</span>
 </code></pre>