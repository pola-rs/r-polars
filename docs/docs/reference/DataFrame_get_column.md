# Get Column (as one Series)

```r
DataFrame_get_column(name)
```

## Arguments

- `name`: name of column to extract as Series

## Returns

Series

get one column by name as series

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>[</span><span class='fl'>1</span>,<span class='op'>]</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>get_column</span><span class='op'>(</span><span class='st'>"Species"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'Species' [cat]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"setosa"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>