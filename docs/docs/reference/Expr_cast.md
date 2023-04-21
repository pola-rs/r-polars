# Cast between DataType(s)

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

```r
Expr_cast(dtype, strict = TRUE)
```

## Arguments

- `dtype`: DataType to cast to.
- `strict`: bool if true an error will be thrown if cast failed at resolve time.

## Returns

Expr

Cast between DataType(s)

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a <span class='op'>=</span> <span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>, b <span class='op'>=</span> <span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>Float64</span>, <span class='cn'>TRUE</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>Int32</span>, <span class='cn'>TRUE</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   ┆ b   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ 1   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ 2   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   ┆ 3   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┘</span>
 </code></pre>