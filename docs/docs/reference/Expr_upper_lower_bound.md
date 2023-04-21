data

# Upper bound

## Format

Method

Method

```r
Expr_upper_bound

Expr_lower_bound
```

## Returns

Expr

Calculate the upper/lower bound. Returns a unit Series with the highest value possible for the dtype of this expression.

## Details

Notice lower bound i32 exported to R is NA_integer_ for now

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>i32<span class='op'>=</span><span class='fl'>1L</span>,f64<span class='op'>=</span><span class='fl'>1</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>upper_bound</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (1, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────┬─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32        ┆ f64 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---        ┆ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32        ┆ f64 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════╪═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2147483647 ┆ inf │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────┴─────┘</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>i32<span class='op'>=</span><span class='fl'>1L</span>,f64<span class='op'>=</span><span class='fl'>1</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lower_bound</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (1, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32         ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---         ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32         ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ -2147483648 ┆ -inf │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────┴──────┘</span>
 </code></pre>