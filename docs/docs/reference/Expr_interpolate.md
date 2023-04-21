# Interpolate `Nulls`

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

```r
Expr_interpolate(method = "linear")
```

## Arguments

- `method`: string 'linear' or 'nearest', default "linear"

## Returns

Expr

Fill nulls with linear interpolation over missing values. Can also be used to regrid data to a new grid - see examples below.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='cn'>NA</span>,<span class='fl'>4</span>,<span class='cn'>NA</span>,<span class='fl'>100</span>,<span class='cn'>NaN</span>,<span class='fl'>150</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>interpolate</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (7, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2.5   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.0   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 52.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 100.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ NaN   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 150.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#x, y interpolation over a grid</span></span></span>
<span class='r-in'><span><span class='va'>df_original_grid</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  grid_points <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>, <span class='fl'>3</span>, <span class='fl'>10</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  values <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>2.0</span>, <span class='fl'>6.0</span>, <span class='fl'>20.0</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df_new_grid</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>grid_points <span class='op'>=</span> <span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>10</span><span class='op'>)</span><span class='op'>*</span><span class='fl'>1.0</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># Interpolate from this to the new grid</span></span></span>
<span class='r-in'><span><span class='va'>df_new_grid</span><span class='op'>$</span><span class='fu'>join</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>df_original_grid</span>, on<span class='op'>=</span><span class='st'>"grid_points"</span>, how<span class='op'>=</span><span class='st'>"left"</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"values"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>interpolate</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (10, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────┬────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ grid_points ┆ values │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---         ┆ ---    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64         ┆ f64    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════╪════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0         ┆ 2.0    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2.0         ┆ 4.0    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.0         ┆ 6.0    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.0         ┆ 8.0    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...         ┆ ...    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 7.0         ┆ 14.0   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 8.0         ┆ 16.0   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 9.0         ┆ 18.0   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 10.0        ┆ 20.0   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────┴────────┘</span>
 </code></pre>