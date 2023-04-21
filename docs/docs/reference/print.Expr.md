# Print expr

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

```r
## S3 method for class 'Expr'
print(x, ...)
```

## Arguments

- `x`: Expr
- `...`: not used

## Returns

self

Print expr

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"some_column"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>over</span><span class='op'>(</span><span class='st'>"some_other_column"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: col("some_column").sum().over([col("some_other_column")])</span>
 </code></pre>