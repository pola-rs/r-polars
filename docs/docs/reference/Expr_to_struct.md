# to_struct

```r
Expr_to_struct()
```

## Returns

Expr

pass expr to pl$struct

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>e</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_struct</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"my_struct"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>e</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: *.as_struct().alias("my_struct")</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>e</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (150, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────────────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ my_struct                     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ struct[5]                     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════════════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {5.1,3.5,1.4,0.2,"setosa"}    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {4.9,3.0,1.4,0.2,"setosa"}    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {4.7,3.2,1.3,0.2,"setosa"}    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {4.6,3.1,1.5,0.2,"setosa"}    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...                           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {6.3,2.5,5.0,1.9,"virginica"} │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {6.5,3.0,5.2,2.0,"virginica"} │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {6.2,3.4,5.4,2.3,"virginica"} │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {5.9,3.0,5.1,1.8,"virginica"} │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────────────────────────┘</span>
 </code></pre>