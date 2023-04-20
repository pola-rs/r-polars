# Reverse

```r
DataFrame_reverse()
```

## Returns

LazyFrame

Reverse the DataFrame.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>reverse</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (32, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────┬───────┬───────┬─────┬─────┬─────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg  ┆ cyl ┆ disp  ┆ hp    ┆ ... ┆ vs  ┆ am  ┆ gear ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ --- ┆ ---   ┆ ---   ┆     ┆ --- ┆ --- ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64 ┆ f64   ┆ f64   ┆     ┆ f64 ┆ f64 ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════╪═══════╪═══════╪═════╪═════╪═════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.4 ┆ 4.0 ┆ 121.0 ┆ 109.0 ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 15.0 ┆ 8.0 ┆ 301.0 ┆ 335.0 ┆ ... ┆ 0.0 ┆ 1.0 ┆ 5.0  ┆ 8.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 19.7 ┆ 6.0 ┆ 145.0 ┆ 175.0 ┆ ... ┆ 0.0 ┆ 1.0 ┆ 5.0  ┆ 6.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 15.8 ┆ 8.0 ┆ 351.0 ┆ 264.0 ┆ ... ┆ 0.0 ┆ 1.0 ┆ 5.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...  ┆ ... ┆ ...   ┆ ...   ┆ ... ┆ ... ┆ ... ┆ ...  ┆ ...  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.4 ┆ 6.0 ┆ 258.0 ┆ 110.0 ┆ ... ┆ 1.0 ┆ 0.0 ┆ 3.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 22.8 ┆ 4.0 ┆ 108.0 ┆ 93.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.0 ┆ 6.0 ┆ 160.0 ┆ 110.0 ┆ ... ┆ 0.0 ┆ 1.0 ┆ 4.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.0 ┆ 6.0 ┆ 160.0 ┆ 110.0 ┆ ... ┆ 0.0 ┆ 1.0 ┆ 4.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────┴───────┴───────┴─────┴─────┴─────┴──────┴──────┘</span>
 </code></pre>