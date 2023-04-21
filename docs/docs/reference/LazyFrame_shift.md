# Shift

```r
LazyFrame_shift(periods = 1)
```

## Arguments

- `periods`: integer Number of periods to shift (may be negative).

## Returns

LazyFrame

Shift the values by a given period.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>shift</span><span class='op'>(</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (32, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬──────┬───────┬───────┬─────┬──────┬──────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg  ┆ cyl  ┆ disp  ┆ hp    ┆ ... ┆ vs   ┆ am   ┆ gear ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---  ┆ ---   ┆ ---   ┆     ┆ ---  ┆ ---  ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64  ┆ f64   ┆ f64   ┆     ┆ f64  ┆ f64  ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪══════╪═══════╪═══════╪═════╪══════╪══════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null ┆ null  ┆ null  ┆ ... ┆ null ┆ null ┆ null ┆ null │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null ┆ null  ┆ null  ┆ ... ┆ null ┆ null ┆ null ┆ null │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.0 ┆ 6.0  ┆ 160.0 ┆ 110.0 ┆ ... ┆ 0.0  ┆ 1.0  ┆ 4.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.0 ┆ 6.0  ┆ 160.0 ┆ 110.0 ┆ ... ┆ 0.0  ┆ 1.0  ┆ 4.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...  ┆ ...  ┆ ...   ┆ ...   ┆ ... ┆ ...  ┆ ...  ┆ ...  ┆ ...  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 26.0 ┆ 4.0  ┆ 120.3 ┆ 91.0  ┆ ... ┆ 0.0  ┆ 1.0  ┆ 5.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 30.4 ┆ 4.0  ┆ 95.1  ┆ 113.0 ┆ ... ┆ 1.0  ┆ 1.0  ┆ 5.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 15.8 ┆ 8.0  ┆ 351.0 ┆ 264.0 ┆ ... ┆ 0.0  ┆ 1.0  ┆ 5.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 19.7 ┆ 6.0  ┆ 145.0 ┆ 175.0 ┆ ... ┆ 0.0  ┆ 1.0  ┆ 5.0  ┆ 6.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴──────┴───────┴───────┴─────┴──────┴──────┴──────┴──────┘</span>
 </code></pre>