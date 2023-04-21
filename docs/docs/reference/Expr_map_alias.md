# Map alias of expression with an R function

```r
Expr_map_alias(fun)
```

## Arguments

- `fun`: an R function which takes a string as input and return a string

## Returns

Expr

Rename the output of an expression by mapping a function over the root name.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>alice<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"alice"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"joe_is_not_root"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>map_alias</span><span class='op'>(</span>\<span class='op'>(</span><span class='va'>x</span><span class='op'>)</span> <span class='fu'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='op'>(</span><span class='va'>x</span>,<span class='st'>"_and_bob"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> map_alias function is experimentally without some thread-safeguards, please report any crashes</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ alice_and_bob │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────────┘</span>
 </code></pre>