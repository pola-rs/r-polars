# Second

## Format

function

## Returns

Expr of second as UInt32

Extract seconds from underlying Datetime representation. Applies to Datetime columns. Returns the integer second number from 0 to 59, or a floating point number from 0 < 60 if `fractional=True` that includes any milli/micro/nanosecond component.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>date <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/numeric.html'>as.numeric</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2001-1-1"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>*</span><span class='fl'>1E6</span><span class='op'>+</span><span class='fl'>456789</span>, <span class='co'>#manually convert to us</span></span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/numeric.html'>as.numeric</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2001-1-1 00:00:6"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>*</span><span class='fl'>1E6</span>,</span></span>
<span class='r-in'><span>  interval <span class='op'>=</span> <span class='st'>"2s654321us"</span>,</span></span>
<span class='r-in'><span>  time_unit <span class='op'>=</span> <span class='st'>"us"</span> <span class='co'>#instruct polars input is us, and store as us</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>second</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"second"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>second</span><span class='op'>(</span>fractional <span class='op'>=</span> <span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"second_frac"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (3, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────────┬────────┬─────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date                    ┆ second ┆ second_frac │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                     ┆ ---    ┆ ---         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[μs]            ┆ u32    ┆ f64         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════════╪════════╪═════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2000-12-31 23:00:00.456 ┆ 0      ┆ 0.456       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2000-12-31 23:00:03.110 ┆ 3      ┆ 3.11        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2000-12-31 23:00:05.764 ┆ 5      ┆ 5.764       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────────┴────────┴─────────────┘</span>
 </code></pre>