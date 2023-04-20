# Repeat by

```r
Expr_repeat_by(by)
```

## Arguments

- `by`: Expr Numeric column that determines how often the values will be repeated. The column will be coerced to UInt32. Give this dtype to make the coercion a no-op.

## Returns

Expr

Repeat the elements in this Series as specified in the given expression. The repeated elements are expanded into a `List`.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"x"</span>,<span class='st'>"y"</span>,<span class='st'>"z"</span><span class='op'>)</span>, n <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>0</span><span class='op'>:</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>repeat_by</span><span class='op'>(</span><span class='st'>"n"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list[str]  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ []         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["y"]      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["z", "z"] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────┘</span>
 </code></pre>