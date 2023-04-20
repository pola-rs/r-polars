# print LazyFrame s3 method

```r
## S3 method for class 'LazyFrame'
print(x, ...)
```

## Arguments

- `x`: DataFrame
- `...`: not used

## Returns

self

print LazyFrame s3 method

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "polars LazyFrame naive plan: (run ldf$describe_optimized_plan() to see the optimized plan)"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"]; PROJECT */5 COLUMNS; SELECTION: "None"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>