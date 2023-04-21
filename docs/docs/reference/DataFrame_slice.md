# Slice

*Source: [R/dataframe__frame.R](https://github.com/pola-rs/r-polars/tree/main/R/dataframe__frame.R)*

```r
DataFrame_slice(offset, length = NULL)
```

## Arguments

- `offset`: integer
- `length`: integer or NULL

## Returns

LazyFrame

Get a slice of this DataFrame.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>slice</span><span class='op'>(</span><span class='fl'>2</span>, <span class='fl'>4</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (4, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────┬───────┬───────┬─────┬─────┬─────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg  ┆ cyl ┆ disp  ┆ hp    ┆ ... ┆ vs  ┆ am  ┆ gear ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ --- ┆ ---   ┆ ---   ┆     ┆ --- ┆ --- ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64 ┆ f64   ┆ f64   ┆     ┆ f64 ┆ f64 ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════╪═══════╪═══════╪═════╪═════╪═════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 22.8 ┆ 4.0 ┆ 108.0 ┆ 93.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.4 ┆ 6.0 ┆ 258.0 ┆ 110.0 ┆ ... ┆ 1.0 ┆ 0.0 ┆ 3.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 18.7 ┆ 8.0 ┆ 360.0 ┆ 175.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 18.1 ┆ 6.0 ┆ 225.0 ┆ 105.0 ┆ ... ┆ 1.0 ┆ 0.0 ┆ 3.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────┴───────┴───────┴─────┴─────┴─────┴──────┴──────┘</span>
<span class='r-in'><span><span class='va'>mtcars</span><span class='op'>[</span><span class='fl'>2</span><span class='op'>:</span><span class='fl'>6</span>,<span class='op'>]</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>                    mpg cyl disp  hp drat    wt  qsec vs am gear carb</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1</span>
 </code></pre>