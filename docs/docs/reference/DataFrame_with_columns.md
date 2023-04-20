# modify/append column(s)

```r
DataFrame_with_columns(...)

DataFrame_with_column(expr)
```

## Arguments

- `...`: any expressions or string column name, or same wrapped in a list
- `expr`: a single expression or string

## Returns

DataFrame

DataFrame

add or modify columns with expressions

## Details

Like dplyr `mutate()` as it keeps unmentioned columns unlike $select().

with_column is derived from with_columns but takes only one expression argument

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Sepal.Length"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>abs</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"abs_SL"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Sepal.Length"</span><span class='op'>)</span><span class='op'>+</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"add_2_SL"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (150, 7)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬─────────────┬──────────────┬─────────────┬───────────┬────────┬──────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Sepal.Length ┆ Sepal.Width ┆ Petal.Length ┆ Petal.Width ┆ Species   ┆ abs_SL ┆ add_2_SL │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---         ┆ ---          ┆ ---         ┆ ---       ┆ ---    ┆ ---      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64          ┆ f64         ┆ f64          ┆ f64         ┆ cat       ┆ f64    ┆ f64      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪═════════════╪══════════════╪═════════════╪═══════════╪════════╪══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.1          ┆ 3.5         ┆ 1.4          ┆ 0.2         ┆ setosa    ┆ 5.1    ┆ 7.1      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.9          ┆ 3.0         ┆ 1.4          ┆ 0.2         ┆ setosa    ┆ 4.9    ┆ 6.9      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.7          ┆ 3.2         ┆ 1.3          ┆ 0.2         ┆ setosa    ┆ 4.7    ┆ 6.7      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.6          ┆ 3.1         ┆ 1.5          ┆ 0.2         ┆ setosa    ┆ 4.6    ┆ 6.6      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...          ┆ ...         ┆ ...          ┆ ...         ┆ ...       ┆ ...    ┆ ...      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.3          ┆ 2.5         ┆ 5.0          ┆ 1.9         ┆ virginica ┆ 6.3    ┆ 8.3      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.5          ┆ 3.0         ┆ 5.2          ┆ 2.0         ┆ virginica ┆ 6.5    ┆ 8.5      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.2          ┆ 3.4         ┆ 5.4          ┆ 2.3         ┆ virginica ┆ 6.2    ┆ 8.2      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.9          ┆ 3.0         ┆ 5.1          ┆ 1.8         ┆ virginica ┆ 5.9    ┆ 7.9      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴─────────────┴──────────────┴─────────────┴───────────┴────────┴──────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#rename columns by naming expression is concidered experimental</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>set_polars_options</span><span class='op'>(</span>named_exprs <span class='op'>=</span> <span class='cn'>TRUE</span><span class='op'>)</span> <span class='co'>#unlock</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $named_exprs</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Sepal.Length"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>abs</span><span class='op'>(</span><span class='op'>)</span>, <span class='co'>#not named expr will keep name "Sepal.Length"</span></span></span>
<span class='r-in'><span>  SW_add_2 <span class='op'>=</span> <span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Sepal.Width"</span><span class='op'>)</span><span class='op'>+</span><span class='fl'>2</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (150, 6)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬─────────────┬──────────────┬─────────────┬───────────┬──────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Sepal.Length ┆ Sepal.Width ┆ Petal.Length ┆ Petal.Width ┆ Species   ┆ SW_add_2 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---         ┆ ---          ┆ ---         ┆ ---       ┆ ---      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64          ┆ f64         ┆ f64          ┆ f64         ┆ cat       ┆ f64      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪═════════════╪══════════════╪═════════════╪═══════════╪══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.1          ┆ 3.5         ┆ 1.4          ┆ 0.2         ┆ setosa    ┆ 5.5      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.9          ┆ 3.0         ┆ 1.4          ┆ 0.2         ┆ setosa    ┆ 5.0      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.7          ┆ 3.2         ┆ 1.3          ┆ 0.2         ┆ setosa    ┆ 5.2      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.6          ┆ 3.1         ┆ 1.5          ┆ 0.2         ┆ setosa    ┆ 5.1      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...          ┆ ...         ┆ ...          ┆ ...         ┆ ...       ┆ ...      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.3          ┆ 2.5         ┆ 5.0          ┆ 1.9         ┆ virginica ┆ 4.5      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.5          ┆ 3.0         ┆ 5.2          ┆ 2.0         ┆ virginica ┆ 5.0      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.2          ┆ 3.4         ┆ 5.4          ┆ 2.3         ┆ virginica ┆ 5.4      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.9          ┆ 3.0         ┆ 5.1          ┆ 1.8         ┆ virginica ┆ 5.0      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴─────────────┴──────────────┴─────────────┴───────────┴──────────┘</span>
 </code></pre>