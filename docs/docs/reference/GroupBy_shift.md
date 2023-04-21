# Shift

```r
GroupBy_shift(periods = 1)
```

## Arguments

- `periods`: integer Number of periods to shift (may be negative).

## Returns

GroupBy

Shift the values by a given period.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>groupby</span><span class='op'>(</span><span class='st'>"cyl"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>shift</span><span class='op'>(</span><span class='fl'>2</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬────────────┬────────────┬────────────┬─────┬───────────┬───────────┬───────────┬───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cyl ┆ mpg        ┆ disp       ┆ hp         ┆ ... ┆ vs        ┆ am        ┆ gear      ┆ carb      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---        ┆ ---        ┆ ---        ┆     ┆ ---       ┆ ---       ┆ ---       ┆ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 ┆ list[f64]  ┆ list[f64]  ┆ list[f64]  ┆     ┆ list[f64] ┆ list[f64] ┆ list[f64] ┆ list[f64] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪════════════╪════════════╪════════════╪═════╪═══════════╪═══════════╪═══════════╪═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.0 ┆ [null,     ┆ [null,     ┆ [null,     ┆ ... ┆ [null,    ┆ [null,    ┆ [null,    ┆ [null,    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     ┆ null, ...  ┆ null, ...  ┆ null, ...  ┆     ┆ null, ... ┆ null, ... ┆ null, ... ┆ null, ... │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     ┆ 26.0]      ┆ 120.3]     ┆ 91.0]      ┆     ┆ 0.0]      ┆ 1.0]      ┆ 5.0]      ┆ 2.0]      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 8.0 ┆ [null,     ┆ [null,     ┆ [null,     ┆ ... ┆ [null,    ┆ [null,    ┆ [null,    ┆ [null,    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     ┆ null, ...  ┆ null, ...  ┆ null, ...  ┆     ┆ null, ... ┆ null, ... ┆ null, ... ┆ null, ... │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     ┆ 19.2]      ┆ 400.0]     ┆ 175.0]     ┆     ┆ 0.0]      ┆ 0.0]      ┆ 3.0]      ┆ 2.0]      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.0 ┆ [null,     ┆ [null,     ┆ [null,     ┆ ... ┆ [null,    ┆ [null,    ┆ [null,    ┆ [null,    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     ┆ null, ...  ┆ null, ...  ┆ null, ...  ┆     ┆ null, ... ┆ null, ... ┆ null, ... ┆ null, ... │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     ┆ 19.2]      ┆ 167.6]     ┆ 123.0]     ┆     ┆ 1.0]      ┆ 0.0]      ┆ 4.0]      ┆ 4.0]      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴────────────┴────────────┴────────────┴─────┴───────────┴───────────┴───────────┴───────────┘</span>
 </code></pre>