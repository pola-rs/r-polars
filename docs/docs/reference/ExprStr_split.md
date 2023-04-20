# split

## Arguments

- `by`: Substring to split by.
- `inclusive`: If True, include the split character/string in the results.

## Returns

List of Utf8 type

Split the string by a substring.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>s <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"foo bar"</span>, <span class='st'>"foo-bar"</span>, <span class='st'>"foo bar baz"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"s"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>split</span><span class='op'>(</span>by<span class='op'>=</span><span class='st'>" "</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ s                     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list[str]             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["foo", "bar"]        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["foo-bar"]           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["foo", "bar", "baz"] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────────────────┘</span>
 </code></pre>