# Var

```r
DataFrame_var(ddof = 1)
```

## Arguments

- `ddof`: integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.

## Returns

A new `DataFrame` object with applied aggregation.

Aggregate the columns of this DataFrame to their variance values.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>var</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (1, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────┬──────────┬────────────┬────────────┬─────┬──────────┬──────────┬──────────┬──────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg       ┆ cyl      ┆ disp       ┆ hp         ┆ ... ┆ vs       ┆ am       ┆ gear     ┆ carb     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---       ┆ ---      ┆ ---        ┆ ---        ┆     ┆ ---      ┆ ---      ┆ ---      ┆ ---      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64       ┆ f64      ┆ f64        ┆ f64        ┆     ┆ f64      ┆ f64      ┆ f64      ┆ f64      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════╪══════════╪════════════╪════════════╪═════╪══════════╪══════════╪══════════╪══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 36.324103 ┆ 3.189516 ┆ 15360.7998 ┆ 4700.86693 ┆ ... ┆ 0.254032 ┆ 0.248992 ┆ 0.544355 ┆ 2.608871 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │           ┆          ┆ 29         ┆ 5          ┆     ┆          ┆          ┆          ┆          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────┴──────────┴────────────┴────────────┴─────┴──────────┴──────────┴──────────┴──────────┘</span>
 </code></pre>