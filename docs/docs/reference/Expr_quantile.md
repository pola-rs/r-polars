# Get quantile value.

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

## Format

a method

```r
Expr_quantile(quantile, interpolation = "nearest")
```

## Arguments

- `quantile`: numeric/Expression 0.0 to 1.0
- `interpolation`: string value from choices "nearest", "higher", "lower", "midpoint", "linear"

## Returns

Expr

Get quantile value.

## Details

`Nulls` are ignored and `NaNs` are ranked as the largest value. For linear interpolation `NaN` poisons `Inf`, that poisons any other value.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='op'>-</span><span class='fl'>5</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>quantile</span><span class='op'>(</span><span class='fl'>.5</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (1, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
 </code></pre>