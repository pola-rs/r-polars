# extract_all

## Arguments

- `pattern`: A valid regex pattern

## Returns

`List[Utf8]` array. Contain null if original value is null or regex capture nothing.

Extracts all matches for the given regex pattern. Extracts each successive non-overlapping regex match in an individual string as an array.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span> foo <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"123 bla 45 asd"</span>, <span class='st'>"xyz 678 910t"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"foo"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>extract_all</span><span class='op'>(</span><span class='st'>r"((\d+))"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"extracted_nrs"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ extracted_nrs  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list[str]      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["123", "45"]  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["678", "910"] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────────┘</span>
 </code></pre>