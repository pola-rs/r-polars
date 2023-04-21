# Lengths arrays in list

*Source: [R/expr__list.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__list.R)*

## Format

function

## Returns

Expr

Get the length of the arrays as UInt32

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>list_of_strs <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a"</span>,<span class='st'>"b"</span><span class='op'>)</span>,<span class='st'>"c"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"list_of_strs"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>lengths</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"list_of_strs_lengths"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬──────────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list_of_strs ┆ list_of_strs_lengths │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---                  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list[str]    ┆ u32                  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪══════════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["a", "b"]   ┆ 2                    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["c"]        ┆ 1                    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴──────────────────────┘</span>
 </code></pre>