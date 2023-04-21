# Diff sublists

*Source: [R/expr__list.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__list.R)*

## Format

function

## Arguments

- `n`: Number of slots to shift
- `null_behavior`: choice "ignore"(default) "drop"

## Returns

Expr

Calculate the n-th discrete difference of every sublist.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>s <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span>,<span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>10L</span>,<span class='fl'>2L</span>,<span class='fl'>1L</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"s"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>diff</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ s                │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---              │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list[i32]        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [null, 1, ... 1] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [null, -8, -1]   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────────┘</span>
 </code></pre>