# Reshape

## Format

Method

```r
Expr_reshape(dims)
```

## Arguments

- `dims`: numeric vec of the dimension sizes. If a -1 is used in any of the dimensions, that dimension is inferred.

## Returns

Expr

Reshape this Expr to a flat Series or a Series of Lists.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>12</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>reshape</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>3</span>,<span class='fl'>4</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │                 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list[i32]       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [1, 2, ... 4]   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [5, 6, ... 8]   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [9, 10, ... 12] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────┘</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>12</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>reshape</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>3</span>,<span class='op'>-</span><span class='fl'>1</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │                 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list[i32]       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [1, 2, ... 4]   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [5, 6, ... 8]   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [9, 10, ... 12] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────┘</span>
 </code></pre>