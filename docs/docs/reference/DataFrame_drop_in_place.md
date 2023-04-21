# Drop in place

*Source: [R/dataframe__frame.R](https://github.com/pola-rs/r-polars/tree/main/R/dataframe__frame.R)*

```r
DataFrame_drop_in_place(name)
```

## Arguments

- `name`: string Name of the column to drop.

## Returns

Series

Drop a single column in-place and return the dropped column.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>dat</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>x</span> <span class='op'>=</span> <span class='va'>dat</span><span class='op'>$</span><span class='fu'>drop_in_place</span><span class='op'>(</span><span class='st'>"Species"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>x</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (150,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'Species' [cat]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"setosa"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"setosa"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"setosa"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"setosa"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"setosa"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"setosa"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"setosa"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"setosa"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"setosa"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"setosa"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"setosa"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"setosa"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	...</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"virginica"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"virginica"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"virginica"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"virginica"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"virginica"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"virginica"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"virginica"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"virginica"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"virginica"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"virginica"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"virginica"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"virginica"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"virginica"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>dat</span><span class='op'>$</span><span class='va'>columns</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width" </span>
 </code></pre>