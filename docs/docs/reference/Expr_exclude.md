# Exclude certain columns from a wildcard/regex selection.

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

```r
Expr_exclude(columns)
```

## Arguments

- `columns`: given param type:
    
     * string: exclude name of column or exclude regex starting with ^and ending with$
     * character vector: exclude all these column names, no regex allowed
     * DataType: Exclude any of this DataType
     * List(DataType): Excldue any of these DataType(s)

## Returns

Expr

You may also use regexes in the exclude list. They must start with `^` and end with `$`.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#make DataFrame</span></span></span>
<span class='r-in'><span> <span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span> <span class='co'>#by name(s)</span></span></span>
<span class='r-in'><span> <span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>exclude</span><span class='op'>(</span><span class='st'>"Species"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (150, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬─────────────┬──────────────┬─────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Sepal.Length ┆ Sepal.Width ┆ Petal.Length ┆ Petal.Width │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---         ┆ ---          ┆ ---         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64          ┆ f64         ┆ f64          ┆ f64         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪═════════════╪══════════════╪═════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.1          ┆ 3.5         ┆ 1.4          ┆ 0.2         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.9          ┆ 3.0         ┆ 1.4          ┆ 0.2         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.7          ┆ 3.2         ┆ 1.3          ┆ 0.2         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.6          ┆ 3.1         ┆ 1.5          ┆ 0.2         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...          ┆ ...         ┆ ...          ┆ ...         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.3          ┆ 2.5         ┆ 5.0          ┆ 1.9         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.5          ┆ 3.0         ┆ 5.2          ┆ 2.0         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.2          ┆ 3.4         ┆ 5.4          ┆ 2.3         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.9          ┆ 3.0         ┆ 5.1          ┆ 1.8         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴─────────────┴──────────────┴─────────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span> <span class='co'>#by type</span></span></span>
<span class='r-in'><span> <span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>exclude</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Categorical</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (150, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬─────────────┬──────────────┬─────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Sepal.Length ┆ Sepal.Width ┆ Petal.Length ┆ Petal.Width │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---         ┆ ---          ┆ ---         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64          ┆ f64         ┆ f64          ┆ f64         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪═════════════╪══════════════╪═════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.1          ┆ 3.5         ┆ 1.4          ┆ 0.2         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.9          ┆ 3.0         ┆ 1.4          ┆ 0.2         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.7          ┆ 3.2         ┆ 1.3          ┆ 0.2         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.6          ┆ 3.1         ┆ 1.5          ┆ 0.2         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...          ┆ ...         ┆ ...          ┆ ...         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.3          ┆ 2.5         ┆ 5.0          ┆ 1.9         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.5          ┆ 3.0         ┆ 5.2          ┆ 2.0         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.2          ┆ 3.4         ┆ 5.4          ┆ 2.3         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.9          ┆ 3.0         ┆ 5.1          ┆ 1.8         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴─────────────┴──────────────┴─────────────┘</span>
<span class='r-in'><span> <span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>exclude</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Categorical</span>,<span class='va'>pl</span><span class='op'>$</span><span class='va'>Float64</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (0, 0)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span> <span class='co'>#by regex</span></span></span>
<span class='r-in'><span> <span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>exclude</span><span class='op'>(</span><span class='st'>"^Sepal.*$"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (150, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬─────────────┬───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Petal.Length ┆ Petal.Width ┆ Species   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---         ┆ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64          ┆ f64         ┆ cat       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪═════════════╪═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.4          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.4          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.3          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.5          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...          ┆ ...         ┆ ...       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.0          ┆ 1.9         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.2          ┆ 2.0         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.4          ┆ 2.3         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.1          ┆ 1.8         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴─────────────┴───────────┘</span>
 </code></pre>