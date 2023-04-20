# Mean

## Format

function

```r
LazyFrame_mean
```

## Returns

A new `LazyFrame` object with applied aggregation.

Aggregate the columns in the DataFrame to their mean value.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>mean</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────┬────────┬────────────┬──────────┬─────┬────────┬─────────┬────────┬────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg       ┆ cyl    ┆ disp       ┆ hp       ┆ ... ┆ vs     ┆ am      ┆ gear   ┆ carb   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---       ┆ ---    ┆ ---        ┆ ---      ┆     ┆ ---    ┆ ---     ┆ ---    ┆ ---    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64       ┆ f64    ┆ f64        ┆ f64      ┆     ┆ f64    ┆ f64     ┆ f64    ┆ f64    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════╪════════╪════════════╪══════════╪═════╪════════╪═════════╪════════╪════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 20.090625 ┆ 6.1875 ┆ 230.721875 ┆ 146.6875 ┆ ... ┆ 0.4375 ┆ 0.40625 ┆ 3.6875 ┆ 2.8125 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────┴────────┴────────────┴──────────┴─────┴────────┴─────────┴────────┴────────┘</span>
 </code></pre>