# Inspect evaluated Series

```r
Expr_inspect(fmt = "{}")
```

## Arguments

- `fmt`: format string, should contain one set of `{}` where object will be printed This formatting mimics python "string".format() use in pypolars. The string can contain any thing but should have exactly one set of curly bracket .

## Returns

Expr

Print the value that this expression evaluates to and pass on the value. The printing will happen when the expression evaluates, not when it is formed.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>inspect</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='st'>"before dropping half the column it was:{}and not it is dropped"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>head</span><span class='op'>(</span><span class='fl'>2</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> before dropping half the column it was:shape: (5,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [i32]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	3</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	5</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> and not it is dropped</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
 </code></pre>