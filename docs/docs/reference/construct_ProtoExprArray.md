# construct proto Expr array from args

```r
construct_ProtoExprArray(...)
```

## Arguments

- `...`: any Expr or string

## Returns

ProtoExprArray object

construct proto Expr array from args

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='fu'>polars</span><span class='fu'>:::</span><span class='fu'><a href='https://rdrr.io/pkg/polars/man/construct_ProtoExprArray.html'>construct_ProtoExprArray</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Species"</span><span class='op'>)</span>,<span class='st'>"Sepal.Width"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;pointer: 0x000003e7c81217a0&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> attr(,"class")</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "ProtoExprArray"</span>
 </code></pre>