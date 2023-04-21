# Sum

## Format

function

```r
LazyFrame_sum
```

## Returns

LazyFrame

Aggregate the columns of this DataFrame to their sum values.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (1, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┬───────┬────────┬────────┬─────┬──────┬──────┬───────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg   ┆ cyl   ┆ disp   ┆ hp     ┆ ... ┆ vs   ┆ am   ┆ gear  ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   ┆ ---   ┆ ---    ┆ ---    ┆     ┆ ---  ┆ ---  ┆ ---   ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64   ┆ f64   ┆ f64    ┆ f64    ┆     ┆ f64  ┆ f64  ┆ f64   ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╪═══════╪════════╪════════╪═════╪══════╪══════╪═══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 642.9 ┆ 198.0 ┆ 7383.1 ┆ 4694.0 ┆ ... ┆ 14.0 ┆ 13.0 ┆ 118.0 ┆ 90.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┴───────┴────────┴────────┴─────┴──────┴──────┴───────┴──────┘</span>
 </code></pre>