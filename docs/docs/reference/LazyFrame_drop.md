# Drop

*Source: [R/lazyframe__lazy.R](https://github.com/pola-rs/r-polars/tree/main/R/lazyframe__lazy.R)*

```r
LazyFrame_drop(columns)
```

## Arguments

- `columns`: character vector Name of the column(s) that should be removed from the dataframe.

## Returns

LazyFrame

Remove columns from the dataframe.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>drop</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"mpg"</span>, <span class='st'>"hp"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "polars LazyFrame naive plan: (run ldf$describe_optimized_plan() to see the optimized plan)"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   DROP</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     DF ["mpg", "cyl", "disp", "hp"]; PROJECT */11 COLUMNS; SELECTION: "None"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>