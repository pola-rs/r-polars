# when-then-otherwise Expr

*Source: [R/whenthen.R](https://github.com/pola-rs/r-polars/tree/main/R/whenthen.R)*

## Arguments

- `predicate`: Into Expr into a boolean mask to branch by
- `expr`: Into Expr value to insert in when() or otherwise()

## Returns

Expr

Start a “when, then, otherwise” expression.

## Details

For the impl nerds: pl$when returns a whenthen object and whenthen returns whenthenthen, except for otherwise(), which will terminate and return an Expr. Otherwise may fail to return an Expr if e.g. two consecutive `when(x)$when(y)`

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='va'>wtt</span> <span class='op'>=</span></span></span>
<span class='r-in'><span>    <span class='va'>pl</span><span class='op'>$</span><span class='fu'>when</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"cyl"</span><span class='op'>)</span><span class='op'>&lt;=</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>then</span><span class='op'>(</span><span class='st'>"&lt;=4cyl"</span><span class='op'>)</span><span class='op'>$</span></span></span>
<span class='r-in'><span>    <span class='fu'>when</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"cyl"</span><span class='op'>)</span><span class='op'>&lt;=</span><span class='fl'>6</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>then</span><span class='op'>(</span><span class='st'>"&lt;=6cyl"</span><span class='op'>)</span><span class='op'>$</span></span></span>
<span class='r-in'><span>    <span class='fu'>otherwise</span><span class='op'>(</span><span class='st'>"&gt;6cyl"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"cyl_groups"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>wtt</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> WHEN [(col("cyl")) &lt;= (4f64)]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> THEN</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	Utf8(&lt;=4cyl)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> OTHERWISE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> WHEN [(col("cyl")) &lt;= (6f64)]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> THEN</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	Utf8(&lt;=6cyl)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> OTHERWISE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	Utf8(&gt;6cyl).alias("cyl_groups")</span>
<span class='r-in'><span>  <span class='va'>df</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span><span class='va'>wtt</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (32, 12)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────┬───────┬───────┬─────┬─────┬──────┬──────┬────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg  ┆ cyl ┆ disp  ┆ hp    ┆ ... ┆ am  ┆ gear ┆ carb ┆ cyl_groups │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ --- ┆ ---   ┆ ---   ┆     ┆ --- ┆ ---  ┆ ---  ┆ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64 ┆ f64   ┆ f64   ┆     ┆ f64 ┆ f64  ┆ f64  ┆ str        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════╪═══════╪═══════╪═════╪═════╪══════╪══════╪════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.0 ┆ 6.0 ┆ 160.0 ┆ 110.0 ┆ ... ┆ 1.0 ┆ 4.0  ┆ 4.0  ┆ &lt;=6cyl     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.0 ┆ 6.0 ┆ 160.0 ┆ 110.0 ┆ ... ┆ 1.0 ┆ 4.0  ┆ 4.0  ┆ &lt;=6cyl     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 22.8 ┆ 4.0 ┆ 108.0 ┆ 93.0  ┆ ... ┆ 1.0 ┆ 4.0  ┆ 1.0  ┆ &lt;=4cyl     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.4 ┆ 6.0 ┆ 258.0 ┆ 110.0 ┆ ... ┆ 0.0 ┆ 3.0  ┆ 1.0  ┆ &lt;=6cyl     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...  ┆ ... ┆ ...   ┆ ...   ┆ ... ┆ ... ┆ ...  ┆ ...  ┆ ...        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 15.8 ┆ 8.0 ┆ 351.0 ┆ 264.0 ┆ ... ┆ 1.0 ┆ 5.0  ┆ 4.0  ┆ &gt;6cyl      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 19.7 ┆ 6.0 ┆ 145.0 ┆ 175.0 ┆ ... ┆ 1.0 ┆ 5.0  ┆ 6.0  ┆ &lt;=6cyl     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 15.0 ┆ 8.0 ┆ 301.0 ┆ 335.0 ┆ ... ┆ 1.0 ┆ 5.0  ┆ 8.0  ┆ &gt;6cyl      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.4 ┆ 4.0 ┆ 121.0 ┆ 109.0 ┆ ... ┆ 1.0 ┆ 4.0  ┆ 2.0  ┆ &lt;=4cyl     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────┴───────┴───────┴─────┴─────┴──────┴──────┴────────────┘</span>
 </code></pre>