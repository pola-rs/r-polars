# split_exact

*Source: [R/expr__string.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__string.R)*

## Arguments

- `by`: Substring to split by.
- `n`: Number of splits to make.
- `inclusive`: If True, include the split_exact character/string in the results.

## Returns

Struct where each of n+1 fields is of Utf8 type

Split the string by a substring using `n` splits. Results in a struct of `n+1` fields. If it cannot make `n` splits, the remaining field elements will be null.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>s <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a_1"</span>, <span class='cn'>NA</span>, <span class='st'>"c"</span>, <span class='st'>"d_4"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"s"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>split_exact</span><span class='op'>(</span>by<span class='op'>=</span><span class='st'>"_"</span>,<span class='fl'>1</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (4, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ s           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ struct[2]   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {"a","1"}   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {null,null} │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {"c",null}  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {"d","4"}   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────┘</span>
 </code></pre>