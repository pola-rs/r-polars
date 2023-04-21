# return polars DataFrame as R data.frame

```r
DataFrame_as_data_frame(...)

# S3 method
as.data.frame.DataFrame()
```

## Arguments

- `...`: any params passed to as.data.frame
- `x`: DataFrame

## Returns

data.frame

data.frame

return polars DataFrame as R data.frame

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>[</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>,<span class='op'>]</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>as_data_frame</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 1          5.1         3.5          1.4         0.2  setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 2          4.9         3.0          1.4         0.2  setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 3          4.7         3.2          1.3         0.2  setosa</span>
 </code></pre>