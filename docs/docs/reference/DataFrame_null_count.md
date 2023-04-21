# Null count

## Format

function

```r
DataFrame_null_count
```

## Returns

DataFrame

Create a new DataFrame that shows the null counts per column.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>x</span> <span class='op'>=</span> <span class='va'>mtcars</span></span></span>
<span class='r-in'><span><span class='va'>x</span><span class='op'>[</span><span class='fl'>1</span>, <span class='fl'>2</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>]</span> <span class='op'>=</span> <span class='cn'>NA</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>x</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>null_count</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┬──────┬─────┬─────┬─────┬─────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg ┆ cyl ┆ disp ┆ hp  ┆ ... ┆ vs  ┆ am  ┆ gear ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- ┆ ---  ┆ --- ┆     ┆ --- ┆ --- ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ u32 ┆ u32 ┆ u32  ┆ u32 ┆     ┆ u32 ┆ u32 ┆ u32  ┆ u32  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╪══════╪═════╪═════╪═════╪═════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0   ┆ 1   ┆ 1    ┆ 0   ┆ ... ┆ 0   ┆ 0   ┆ 0    ┆ 0    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┴──────┴─────┴─────┴─────┴─────┴──────┴──────┘</span>
 </code></pre>