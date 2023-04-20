# strftime

## Format

function

## Arguments

- `fmt`: string format very much like in R passed to chrono

## Returns

Date/Datetime expr

Format Date/Datetime with a formatting rule. See `chrono strftime/strptime<https://docs.rs/chrono/latest/chrono/format/strftime/index.html>`_.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='op'>(</span><span class='st'>"2021-01-02 12:13:14"</span>,tz<span class='op'>=</span><span class='st'>"GMT"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>strftime</span><span class='op'>(</span><span class='st'>"this is the year: %Y"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "this is the year: 2021"</span>
 </code></pre>