# Epoch

*Source: [R/expr__datetime.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__datetime.R)*

## Format

function

## Arguments

- `tu`: string option either 'ns', 'us', 'ms', 's' or 'd'

## Returns

Expr of epoch as UInt32

Get the time passed since the Unix EPOCH in the give time unit.

## Details

ns and perhaps us will exceed integerish limit if returning to R as flaot64/double.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2022-1-1"</span><span class='op'>)</span>,lazy <span class='op'>=</span> <span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>epoch</span><span class='op'>(</span><span class='st'>"ns"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'literal' [i64]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1640995200000000000</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2022-1-1"</span><span class='op'>)</span>,lazy <span class='op'>=</span> <span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>epoch</span><span class='op'>(</span><span class='st'>"ms"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'literal' [i64]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1640995200000</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2022-1-1"</span><span class='op'>)</span>,lazy <span class='op'>=</span> <span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>epoch</span><span class='op'>(</span><span class='st'>"s"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'literal' [i64]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1640995200</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2022-1-1"</span><span class='op'>)</span>,lazy <span class='op'>=</span> <span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>epoch</span><span class='op'>(</span><span class='st'>"d"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'literal' [i32]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	18993</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>