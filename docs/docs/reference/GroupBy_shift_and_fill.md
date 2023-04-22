# Shift and fill

*Source: [R/groupby.R](https://github.com/pola-rs/r-polars/tree/main/R/groupby.R)*

```r
GroupBy_shift_and_fill(fill_value, periods = 1)
```

## Arguments

- `fill_value`: fill None values with the result of this expression.
- `periods`: integer Number of periods to shift (may be negative).

## Returns

GroupBy

Shift and fill the values by a given period.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>groupby</span><span class='op'>(</span><span class='st'>"cyl"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>shift_and_fill</span><span class='op'>(</span><span class='fl'>99</span>, <span class='fl'>1</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬────────────┬────────────┬────────────┬─────┬───────────┬───────────┬───────────┬───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cyl ┆ mpg        ┆ disp       ┆ hp         ┆ ... ┆ vs        ┆ am        ┆ gear      ┆ carb      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---        ┆ ---        ┆ ---        ┆     ┆ ---       ┆ ---       ┆ ---       ┆ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 ┆ list[f64]  ┆ list[f64]  ┆ list[f64]  ┆     ┆ list[f64] ┆ list[f64] ┆ list[f64] ┆ list[f64] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪════════════╪════════════╪════════════╪═════╪═══════════╪═══════════╪═══════════╪═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.0 ┆ [99.0,     ┆ [99.0,     ┆ [99.0,     ┆ ... ┆ [99.0,    ┆ [99.0,    ┆ [99.0,    ┆ [99.0,    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     ┆ 21.0, ...  ┆ 160.0, ... ┆ 110.0, ... ┆     ┆ 0.0, ...  ┆ 1.0, ...  ┆ 4.0, ...  ┆ 4.0, ...  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     ┆ 17.8]      ┆ 167.6]     ┆ 123.0]     ┆     ┆ 1.0]      ┆ 0.0]      ┆ 4.0]      ┆ 4.0]      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.0 ┆ [99.0,     ┆ [99.0,     ┆ [99.0,     ┆ ... ┆ [99.0,    ┆ [99.0,    ┆ [99.0,    ┆ [99.0,    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     ┆ 22.8, ...  ┆ 108.0, ... ┆ 93.0, ...  ┆     ┆ 1.0, ...  ┆ 1.0, ...  ┆ 4.0, ...  ┆ 1.0, ...  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     ┆ 30.4]      ┆ 95.1]      ┆ 113.0]     ┆     ┆ 1.0]      ┆ 1.0]      ┆ 5.0]      ┆ 2.0]      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 8.0 ┆ [99.0,     ┆ [99.0,     ┆ [99.0,     ┆ ... ┆ [99.0,    ┆ [99.0,    ┆ [99.0,    ┆ [99.0,    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     ┆ 18.7, ...  ┆ 360.0, ... ┆ 175.0, ... ┆     ┆ 0.0, ...  ┆ 0.0, ...  ┆ 3.0, ...  ┆ 2.0, ...  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     ┆ 15.8]      ┆ 351.0]     ┆ 264.0]     ┆     ┆ 0.0]      ┆ 1.0]      ┆ 5.0]      ┆ 4.0]      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴────────────┴────────────┴────────────┴─────┴───────────┴───────────┴───────────┴───────────┘</span>
 </code></pre>