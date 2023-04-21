# Drop nulls

*Source: [R/dataframe__frame.R](https://github.com/pola-rs/r-polars/tree/main/R/dataframe__frame.R)*

```r
DataFrame_drop_nulls(subset = NULL)
```

## Arguments

- `subset`: string or vector of strings. Column name(s) for which null values are considered. If set to NULL (default), use all columns.

## Returns

DataFrame

Drop all rows that contain null values.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>tmp</span> <span class='op'>=</span> <span class='va'>mtcars</span></span></span>
<span class='r-in'><span><span class='va'>tmp</span><span class='op'>[</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>, <span class='st'>"mpg"</span><span class='op'>]</span> <span class='op'>=</span> <span class='cn'>NA</span></span></span>
<span class='r-in'><span><span class='va'>tmp</span><span class='op'>[</span><span class='fl'>4</span>, <span class='st'>"hp"</span><span class='op'>]</span> <span class='op'>=</span> <span class='cn'>NA</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>tmp</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>drop_nulls</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='va'>height</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 28</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>tmp</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>drop_nulls</span><span class='op'>(</span><span class='st'>"mpg"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>height</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 29</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>tmp</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>drop_nulls</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"mpg"</span>, <span class='st'>"hp"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='va'>height</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 28</span>
 </code></pre>