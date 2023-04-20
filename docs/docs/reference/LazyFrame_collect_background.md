# New DataFrame from LazyFrame_object$collect()

```r
LazyFrame_collect_background()
```

## Returns

collected `DataFrame`

collect DataFrame by lazy query

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>filter</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Species"</span><span class='op'>)</span><span class='op'>==</span><span class='st'>"setosa"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (50, 5)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬─────────────┬──────────────┬─────────────┬─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Sepal.Length ┆ Sepal.Width ┆ Petal.Length ┆ Petal.Width ┆ Species │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---         ┆ ---          ┆ ---         ┆ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64          ┆ f64         ┆ f64          ┆ f64         ┆ cat     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪═════════════╪══════════════╪═════════════╪═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.1          ┆ 3.5         ┆ 1.4          ┆ 0.2         ┆ setosa  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.9          ┆ 3.0         ┆ 1.4          ┆ 0.2         ┆ setosa  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.7          ┆ 3.2         ┆ 1.3          ┆ 0.2         ┆ setosa  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.6          ┆ 3.1         ┆ 1.5          ┆ 0.2         ┆ setosa  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...          ┆ ...         ┆ ...          ┆ ...         ┆ ...     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.1          ┆ 3.8         ┆ 1.6          ┆ 0.2         ┆ setosa  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.6          ┆ 3.2         ┆ 1.4          ┆ 0.2         ┆ setosa  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.3          ┆ 3.7         ┆ 1.5          ┆ 0.2         ┆ setosa  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.0          ┆ 3.3         ┆ 1.4          ┆ 0.2         ┆ setosa  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴─────────────┴──────────────┴─────────────┴─────────┘</span>
 </code></pre>