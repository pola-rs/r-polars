# Std

```r
DataFrame_std(ddof = 1)
```

## Arguments

- `ddof`: integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.

## Returns

A new `DataFrame` object with applied aggregation.

Aggregate the columns of this DataFrame to their standard deviation values.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>std</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────┬──────────┬────────────┬───────────┬─────┬──────────┬──────────┬──────────┬────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg      ┆ cyl      ┆ disp       ┆ hp        ┆ ... ┆ vs       ┆ am       ┆ gear     ┆ carb   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---      ┆ ---      ┆ ---        ┆ ---       ┆     ┆ ---      ┆ ---      ┆ ---      ┆ ---    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64      ┆ f64      ┆ f64        ┆ f64       ┆     ┆ f64      ┆ f64      ┆ f64      ┆ f64    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════╪══════════╪════════════╪═══════════╪═════╪══════════╪══════════╪══════════╪════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.026948 ┆ 1.785922 ┆ 123.938694 ┆ 68.562868 ┆ ... ┆ 0.504016 ┆ 0.498991 ┆ 0.737804 ┆ 1.6152 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────┴──────────┴────────────┴───────────┴─────┴──────────┴──────────┴──────────┴────────┘</span>
 </code></pre>