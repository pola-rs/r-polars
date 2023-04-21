# Concat

## Arguments

- `delimiter`: string The delimiter to insert between consecutive string values.

## Returns

Expr of Utf8 concatenated

Vertically concat the values in the Series to a single string value.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#concatenate a Series of strings to a single string</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>foo <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"1"</span>, <span class='cn'>NA</span>, <span class='fl'>2</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"foo"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>concat</span><span class='op'>(</span><span class='st'>"-"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (1, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1-null-2 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#Series list of strings to Series of concatenated strings</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>bar <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a"</span>,<span class='st'>"b"</span>, <span class='st'>"c"</span><span class='op'>)</span>, <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"1"</span>,<span class='st'>"2"</span>,<span class='cn'>NA</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"bar"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>eval</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>concat</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>first</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bar      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a-b-c    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1-2-null │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────┘</span>
 </code></pre>