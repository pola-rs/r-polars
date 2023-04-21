# Max

```r
DataFrame_max()
```

## Returns

A new `DataFrame` object with applied aggregation.

Aggregate the columns in the DataFrame to their maximum value.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>max</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────┬───────┬───────┬─────┬─────┬─────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg  ┆ cyl ┆ disp  ┆ hp    ┆ ... ┆ vs  ┆ am  ┆ gear ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ --- ┆ ---   ┆ ---   ┆     ┆ --- ┆ --- ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64 ┆ f64   ┆ f64   ┆     ┆ f64 ┆ f64 ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════╪═══════╪═══════╪═════╪═════╪═════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 33.9 ┆ 8.0 ┆ 472.0 ┆ 335.0 ┆ ... ┆ 1.0 ┆ 1.0 ┆ 5.0  ┆ 8.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────┴───────┴───────┴─────┴─────┴─────┴──────┴──────┘</span>
 </code></pre>