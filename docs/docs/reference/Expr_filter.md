# Filter a single column.

## Format

a method

```r
Expr_filter(predicate)

Expr_where(predicate)
```

## Arguments

- `predicate`: Expr or something `Into<Expr>`. Should be a boolean expression.

## Returns

Expr

Mostly useful in an aggregation context. If you want to filter on a DataFrame level, use `LazyFrame.filter`.

where() is an alias for pl$filter

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  group_col <span class='op'>=</span>  <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"g1"</span>, <span class='st'>"g1"</span>, <span class='st'>"g2"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  b <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>, <span class='fl'>2</span>, <span class='fl'>3</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>groupby</span><span class='op'>(</span><span class='st'>"group_col"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>agg</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"b"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>filter</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"b"</span><span class='op'>)</span> <span class='op'>&lt;</span> <span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"lt"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"b"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>filter</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"b"</span><span class='op'>)</span> <span class='op'>&gt;=</span> <span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"gte"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────┬──────┬─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ group_col ┆ lt   ┆ gte │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---       ┆ ---  ┆ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str       ┆ f64  ┆ f64 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════╪══════╪═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ g2        ┆ null ┆ 3.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ g1        ┆ 1.0  ┆ 2.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────┴──────┴─────┘</span>
 </code></pre>