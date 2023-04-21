# Tail

```r
LazyFrame_tail(n)
```

## Arguments

- `n`: positive numeric or integer number not larger than 2^32

## Returns

A new `LazyFrame` object with applied filter.

take last n rows of query

## Details

any number will converted to u32. Negative raises error

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>tail</span><span class='op'>(</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────┬───────┬───────┬─────┬─────┬─────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg  ┆ cyl ┆ disp  ┆ hp    ┆ ... ┆ vs  ┆ am  ┆ gear ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ --- ┆ ---   ┆ ---   ┆     ┆ --- ┆ --- ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64 ┆ f64   ┆ f64   ┆     ┆ f64 ┆ f64 ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════╪═══════╪═══════╪═════╪═════╪═════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 15.0 ┆ 8.0 ┆ 301.0 ┆ 335.0 ┆ ... ┆ 0.0 ┆ 1.0 ┆ 5.0  ┆ 8.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.4 ┆ 4.0 ┆ 121.0 ┆ 109.0 ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────┴───────┴───────┴─────┴─────┴─────┴──────┴──────┘</span>
 </code></pre>