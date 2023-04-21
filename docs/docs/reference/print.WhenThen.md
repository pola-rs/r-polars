# print When

```r
## S3 method for class 'WhenThen'
print(x, ...)
```

## Arguments

- `x`: When object
- `...`: not used

## Returns

self

print When

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>when</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>&gt;</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>then</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='st'>"more than two"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars WhenThen { predicate: Expr([(col("a")) &gt; (2f64)]), then: Expr(Utf8(more than two)) }</span>
 </code></pre>