# Drop

*Source: [R/dataframe__frame.R](https://github.com/pola-rs/r-polars/tree/main/R/dataframe__frame.R)*

```r
DataFrame_drop(columns)
```

## Arguments

- `columns`: character vector Name of the column(s) that should be removed from the dataframe.

## Returns

DataFrame

Remove columns from the dataframe.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>drop</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"mpg"</span>, <span class='st'>"hp"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (32, 9)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬───────┬──────┬───────┬─────┬─────┬─────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cyl ┆ disp  ┆ drat ┆ wt    ┆ ... ┆ vs  ┆ am  ┆ gear ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---   ┆ ---  ┆ ---   ┆     ┆ --- ┆ --- ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 ┆ f64   ┆ f64  ┆ f64   ┆     ┆ f64 ┆ f64 ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═══════╪══════╪═══════╪═════╪═════╪═════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.0 ┆ 160.0 ┆ 3.9  ┆ 2.62  ┆ ... ┆ 0.0 ┆ 1.0 ┆ 4.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.0 ┆ 160.0 ┆ 3.9  ┆ 2.875 ┆ ... ┆ 0.0 ┆ 1.0 ┆ 4.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.0 ┆ 108.0 ┆ 3.85 ┆ 2.32  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.0 ┆ 258.0 ┆ 3.08 ┆ 3.215 ┆ ... ┆ 1.0 ┆ 0.0 ┆ 3.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ... ┆ ...   ┆ ...  ┆ ...   ┆ ... ┆ ... ┆ ... ┆ ...  ┆ ...  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 8.0 ┆ 351.0 ┆ 4.22 ┆ 3.17  ┆ ... ┆ 0.0 ┆ 1.0 ┆ 5.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.0 ┆ 145.0 ┆ 3.62 ┆ 2.77  ┆ ... ┆ 0.0 ┆ 1.0 ┆ 5.0  ┆ 6.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 8.0 ┆ 301.0 ┆ 3.54 ┆ 3.57  ┆ ... ┆ 0.0 ┆ 1.0 ┆ 5.0  ┆ 8.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.0 ┆ 121.0 ┆ 4.11 ┆ 2.78  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴───────┴──────┴───────┴─────┴─────┴─────┴──────┴──────┘</span>
 </code></pre>