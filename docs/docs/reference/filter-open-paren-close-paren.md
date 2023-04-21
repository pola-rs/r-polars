# filter DataFrame

```r
DataFrame_filter(bool_expr)
```

## Arguments

- `bool_expr`: Polars expression which will evaluate to a bool pl$Series

## Returns

filtered DataFrame

DataFrame$filter(bool_expr)

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>filter</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Sepal.Length"</span><span class='op'>)</span> <span class='op'>&gt;</span> <span class='fl'>5</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (118, 5)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬─────────────┬──────────────┬─────────────┬───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Sepal.Length ┆ Sepal.Width ┆ Petal.Length ┆ Petal.Width ┆ Species   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---         ┆ ---          ┆ ---         ┆ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64          ┆ f64         ┆ f64          ┆ f64         ┆ cat       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪═════════════╪══════════════╪═════════════╪═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.1          ┆ 3.5         ┆ 1.4          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.4          ┆ 3.9         ┆ 1.7          ┆ 0.4         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.4          ┆ 3.7         ┆ 1.5          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.8          ┆ 4.0         ┆ 1.2          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...          ┆ ...         ┆ ...          ┆ ...         ┆ ...       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.3          ┆ 2.5         ┆ 5.0          ┆ 1.9         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.5          ┆ 3.0         ┆ 5.2          ┆ 2.0         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.2          ┆ 3.4         ┆ 5.4          ┆ 2.3         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.9          ┆ 3.0         ┆ 5.1          ┆ 1.8         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴─────────────┴──────────────┴─────────────┴───────────┘</span>
 </code></pre>