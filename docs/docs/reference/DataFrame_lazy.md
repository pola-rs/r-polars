data

# New LazyFrame from DataFrame_object$lazy()

## Format

An object of class `character` of length 1.

```r
DataFrame_lazy
```

## Returns

a LazyFrame

Start a new lazy query from a DataFrame

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "polars LazyFrame naive plan: (run ldf$describe_optimized_plan() to see the optimized plan)"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"]; PROJECT */5 COLUMNS; SELECTION: "None"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#use of lazy method</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>filter</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Sepal.Length"</span><span class='op'>)</span> <span class='op'>&gt;=</span> <span class='fl'>7.7</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 5)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬─────────────┬──────────────┬─────────────┬───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Sepal.Length ┆ Sepal.Width ┆ Petal.Length ┆ Petal.Width ┆ Species   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---         ┆ ---          ┆ ---         ┆ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64          ┆ f64         ┆ f64          ┆ f64         ┆ cat       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪═════════════╪══════════════╪═════════════╪═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 7.7          ┆ 3.8         ┆ 6.7          ┆ 2.2         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 7.7          ┆ 2.6         ┆ 6.9          ┆ 2.3         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 7.7          ┆ 2.8         ┆ 6.7          ┆ 2.0         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 7.9          ┆ 3.8         ┆ 6.4          ┆ 2.0         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 7.7          ┆ 3.0         ┆ 6.1          ┆ 2.3         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴─────────────┴──────────────┴─────────────┴───────────┘</span>
 </code></pre>