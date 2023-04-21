data

# Explode a list or utf8 Series.

## Format

a method

a method

```r
Expr_explode

Expr_flatten
```

## Returns

Expr

This means that every item is expanded to a new row.

( flatten is an alias for explode )

## Details

explode/flatten does not support categorical

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='va'>letters</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>explode</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>take</span><span class='op'>(</span><span class='fl'>0</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (6, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ b   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ c   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ d   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ e   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>listed_group_df</span> <span class='op'>=</span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>[</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>,<span class='fl'>51</span><span class='op'>:</span><span class='fl'>53</span><span class='op'>)</span>,<span class='op'>]</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>groupby</span><span class='op'>(</span><span class='st'>"Species"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>agg</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>listed_group_df</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 5)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────┬─────────────────┬─────────────────┬─────────────────┬─────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Species    ┆ Sepal.Length    ┆ Sepal.Width     ┆ Petal.Length    ┆ Petal.Width     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---        ┆ ---             ┆ ---             ┆ ---             ┆ ---             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cat        ┆ list[f64]       ┆ list[f64]       ┆ list[f64]       ┆ list[f64]       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════╪═════════════════╪═════════════════╪═════════════════╪═════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ versicolor ┆ [7.0, 6.4, 6.9] ┆ [3.2, 3.2, 3.1] ┆ [4.7, 4.5, 4.9] ┆ [1.4, 1.5, 1.5] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ setosa     ┆ [5.1, 4.9, 4.7] ┆ [3.5, 3.0, 3.2] ┆ [1.4, 1.4, 1.3] ┆ [0.2, 0.2, 0.2] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────┴─────────────────┴─────────────────┴─────────────────┴─────────────────┘</span>
<span class='r-in'><span><span class='va'>vectors_df</span> <span class='op'>=</span> <span class='va'>listed_group_df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"Sepal.Width"</span>,<span class='st'>"Sepal.Length"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>explode</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>vectors_df</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (6, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────┬──────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Sepal.Width ┆ Sepal.Length │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---         ┆ ---          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64         ┆ f64          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════╪══════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.2         ┆ 7.0          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.2         ┆ 6.4          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.1         ┆ 6.9          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.5         ┆ 5.1          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.0         ┆ 4.9          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.2         ┆ 4.7          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────┴──────────────┘</span>
 </code></pre>