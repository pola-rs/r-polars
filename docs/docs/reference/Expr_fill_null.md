# Fill Nulls with a value or strategy.

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

## Format

a method

```r
Expr_fill_null(value = NULL, strategy = NULL, limit = NULL)
```

## Arguments

- `value`: Expr or `Into<Expr>` to fill Null values with
- `strategy`: default NULL else 'forward', 'backward', 'min', 'max', 'mean', 'zero', 'one'
- `limit`: Number of consecutive null values to fill when using the 'forward' or 'backward' strategy.

## Returns

Expr

Shift the values by value or as strategy.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>0</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>shift_and_fill</span><span class='op'>(</span><span class='op'>-</span><span class='fl'>2</span>, fill_value <span class='op'>=</span> <span class='fl'>42</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"shift-2"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>0</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>shift_and_fill</span><span class='op'>(</span><span class='fl'>2</span>, fill_value <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>42</span><span class='op'>)</span><span class='op'>/</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"shift+2"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (4, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────┬─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ shift-2 ┆ shift+2 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---     ┆ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64     ┆ f64     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════╪═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2.0     ┆ 21.0    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.0     ┆ 21.0    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 42.0    ┆ 0.0     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 42.0    ┆ 1.0     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────┴─────────┘</span>
 </code></pre>