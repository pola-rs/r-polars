# chek if x is a valid RPolarsDataType

```r
is_polars_dtype(x, include_unknown = FALSE)
```

## Arguments

- `x`: a candidate

## Returns

a list DataType with an inner DataType

chek if x is a valid RPolarsDataType

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='fu'>polars</span><span class='fu'>:::</span><span class='fu'><a href='https://rdrr.io/pkg/polars/man/is_polars_dtype.html'>is_polars_dtype</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Int64</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
 </code></pre>