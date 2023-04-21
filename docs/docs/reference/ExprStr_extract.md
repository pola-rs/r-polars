# extract

*Source: [R/expr__string.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__string.R)*

## Arguments

- `pattern`: A valid regex pattern
- `group_index`: Index of the targeted capture group. Group 0 mean the whole pattern, first group begin at index 1. Default to the first capture group.

## Returns

Utf8 array. Contain null if original value is null or regex capture nothing.

Extract the target capture group from provided patterns.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  a <span class='op'>=</span>  <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>    <span class='st'>"http://vote.com/ballon_dor?candidate=messi&amp;ref=polars"</span>,</span></span>
<span class='r-in'><span>    <span class='st'>"http://vote.com/ballon_dor?candidat=jorginho&amp;ref=polars"</span>,</span></span>
<span class='r-in'><span>    <span class='st'>"http://vote.com/ballon_dor?candidate=ronaldo&amp;ref=polars"</span></span></span>
<span class='r-in'><span>  <span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>extract</span><span class='op'>(</span><span class='st'>r"(candidate=(\w+))"</span>, <span class='fl'>1</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ messi   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ronaldo │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────┘</span>
 </code></pre>