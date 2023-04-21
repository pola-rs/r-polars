# Days

*Source: [R/expr__datetime.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__datetime.R)*

## Format

function

## Returns

Expr of i64

Extract the days from a Duration type.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  date <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>date_range</span><span class='op'>(</span>low <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2020-3-1"</span><span class='op'>)</span>, high <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='op'>(</span><span class='st'>"2020-5-1"</span><span class='op'>)</span>, interval <span class='op'>=</span> <span class='st'>"1mo"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"date"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>diff</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dt</span><span class='op'>$</span><span class='fu'>days</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"days_diff"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────┬───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ date                ┆ days_diff │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                 ┆ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ datetime[μs]        ┆ i64       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════╪═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-03-01 00:00:00 ┆ null      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-04-01 00:00:00 ┆ 31        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2020-05-01 00:00:00 ┆ 30        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────┴───────────┘</span>
 </code></pre>