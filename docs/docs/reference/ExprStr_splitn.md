# splitn

## Arguments

- `by`: Substring to split by.
- `n`: Number of splits to make.

## Returns

Struct where each of n+1 fields is of Utf8 type

Split the string by a substring, restricted to returning at most `n` items. If the number of possible splits is less than `n-1`, the remaining field elements will be null. If the number of possible splits is `n-1` or greater, the last (nth) substring will contain the remainder of the string.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>s <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a_1"</span>, <span class='cn'>NA</span>, <span class='st'>"c"</span>, <span class='st'>"d_4"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"s"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>splitn</span><span class='op'>(</span>by<span class='op'>=</span><span class='st'>"_"</span>,<span class='fl'>0</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ s         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ struct[1] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {null}    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"s"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>splitn</span><span class='op'>(</span>by<span class='op'>=</span><span class='st'>"_"</span>,<span class='fl'>1</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ s         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ struct[1] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {"a_1"}   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {null}    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {"c"}     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {"d_4"}   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"s"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>splitn</span><span class='op'>(</span>by<span class='op'>=</span><span class='st'>"_"</span>,<span class='fl'>2</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 1)</span>
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