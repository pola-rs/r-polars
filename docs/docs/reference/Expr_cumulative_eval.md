# Cumulative eval

```r
Expr_cumulative_eval(expr, min_periods = 1L, parallel = FALSE)
```

## Arguments

- `expr`: Expression to evaluate
- `min_periods`: Number of valid values there should be in the window before the expression is evaluated. valid values = `length - null_count`
- `parallel`: Run in parallel. Don't do this in a groupby or another operation that already has much parallelization.

## Returns

Expr

Run an expression over a sliding window that increases `1` slot every iteration.

## Details

Warnings

This functionality is experimental and may change without it being considered a breaking change. This can be really slow as it can have `O(n^2)` complexity. Don't use this for operations that visit all elements.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cumulative_eval</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>element</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>first</span><span class='op'>(</span><span class='op'>)</span><span class='op'>-</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>element</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>last</span><span class='op'>(</span><span class='op'>)</span> <span class='op'>**</span> <span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1]   0  -3  -8 -15 -24</span>
 </code></pre>