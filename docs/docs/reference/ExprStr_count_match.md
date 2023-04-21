# count_match

*Source: [R/expr__string.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__string.R)*

## Arguments

- `pattern`: A valid regex pattern

## Returns

UInt32 array. Contain null if original value is null or regex capture nothing.

Count all successive non-overlapping regex matches.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span> foo <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"123 bla 45 asd"</span>, <span class='st'>"xyz 678 910t"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"foo"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>count_match</span><span class='op'>(</span><span class='st'>r"{(\d)}"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"count digits"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ count digits │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ u32          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┘</span>
 </code></pre>