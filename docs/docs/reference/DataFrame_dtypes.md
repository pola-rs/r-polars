# DataFrame dtypes

*Source: [R/dataframe__frame.R](https://github.com/pola-rs/r-polars/tree/main/R/dataframe__frame.R)*

```r
DataFrame_dtypes()

DataFrame_schema()
```

## Returns

width as numeric scalar

width as numeric scalar

Get dtypes of columns in DataFrame. Dtypes can also be found in column headers when printing the DataFrame.

Get dtypes of columns in DataFrame. Dtypes can also be found in column headers when printing the DataFrame.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='va'>dtypes</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[1]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Float64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[2]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Float64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[3]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Float64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[4]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Float64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[5]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Categorical(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     Some(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         Local(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             LargeUtf8Array[setosa, versicolor, virginica],</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         ),</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     ),</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> )</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='va'>schema</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Sepal.Length</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Float64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Sepal.Width</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Float64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Petal.Length</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Float64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Petal.Width</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Float64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Species</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Categorical(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     Some(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         Local(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             LargeUtf8Array[setosa, versicolor, virginica],</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         ),</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     ),</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> )</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>