# LazyFrame Sort

```r
LazyFrame_sort(by, ..., descending = FALSE, nulls_last = FALSE)
```

## Arguments

- `by`: Column(s) to sort by. Column name strings, character vector of column names, or Iterable Into  (e.g. one Expr, or list mixed Expr and column name strings).
- `...`: more columns to sort by as above but provided one Expr per argument.
- `descending`: Sort descending? Default = FALSE logical vector of length 1 or same length as number of Expr's from above by + ....
- `nulls_last`: Bool default FALSE, place all nulls_last?

## Returns

LazyFrame

sort a LazyFrame by on or more Expr

## Details

by and ... args allow to either provide e.g. a list of Expr or something which can be converted into an Expr e.g. `$sort(list(e1,e2,e3))`, or provide each Expr as an individual argument `$sort(e1,e2,e3)`´ ... or both.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>mtcars</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='va'>mpg</span><span class='op'>[</span><span class='fl'>1</span><span class='op'>]</span> <span class='op'>=</span> <span class='cn'>NA</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>df</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort</span><span class='op'>(</span><span class='st'>"mpg"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (32, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────┬───────┬───────┬─────┬─────┬─────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg  ┆ cyl ┆ disp  ┆ hp    ┆ ... ┆ vs  ┆ am  ┆ gear ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ --- ┆ ---   ┆ ---   ┆     ┆ --- ┆ --- ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64 ┆ f64   ┆ f64   ┆     ┆ f64 ┆ f64 ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════╪═══════╪═══════╪═════╪═════╪═════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ 6.0 ┆ 160.0 ┆ 110.0 ┆ ... ┆ 0.0 ┆ 1.0 ┆ 4.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 10.4 ┆ 8.0 ┆ 472.0 ┆ 205.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 10.4 ┆ 8.0 ┆ 460.0 ┆ 215.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 13.3 ┆ 8.0 ┆ 350.0 ┆ 245.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...  ┆ ... ┆ ...   ┆ ...   ┆ ... ┆ ... ┆ ... ┆ ...  ┆ ...  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 30.4 ┆ 4.0 ┆ 75.7  ┆ 52.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 30.4 ┆ 4.0 ┆ 95.1  ┆ 113.0 ┆ ... ┆ 1.0 ┆ 1.0 ┆ 5.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 32.4 ┆ 4.0 ┆ 78.7  ┆ 66.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 33.9 ┆ 4.0 ┆ 71.1  ┆ 65.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────┴───────┴───────┴─────┴─────┴─────┴──────┴──────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort</span><span class='op'>(</span><span class='st'>"mpg"</span>, nulls_last <span class='op'>=</span> <span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (32, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────┬───────┬───────┬─────┬─────┬─────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg  ┆ cyl ┆ disp  ┆ hp    ┆ ... ┆ vs  ┆ am  ┆ gear ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ --- ┆ ---   ┆ ---   ┆     ┆ --- ┆ --- ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64 ┆ f64   ┆ f64   ┆     ┆ f64 ┆ f64 ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════╪═══════╪═══════╪═════╪═════╪═════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 10.4 ┆ 8.0 ┆ 472.0 ┆ 205.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 10.4 ┆ 8.0 ┆ 460.0 ┆ 215.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 13.3 ┆ 8.0 ┆ 350.0 ┆ 245.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 14.3 ┆ 8.0 ┆ 360.0 ┆ 245.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...  ┆ ... ┆ ...   ┆ ...   ┆ ... ┆ ... ┆ ... ┆ ...  ┆ ...  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 30.4 ┆ 4.0 ┆ 95.1  ┆ 113.0 ┆ ... ┆ 1.0 ┆ 1.0 ┆ 5.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 32.4 ┆ 4.0 ┆ 78.7  ┆ 66.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 33.9 ┆ 4.0 ┆ 71.1  ┆ 65.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ 6.0 ┆ 160.0 ┆ 110.0 ┆ ... ┆ 0.0 ┆ 1.0 ┆ 4.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────┴───────┴───────┴─────┴─────┴─────┴──────┴──────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort</span><span class='op'>(</span><span class='st'>"cyl"</span>, <span class='st'>"mpg"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (32, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────┬───────┬───────┬─────┬─────┬─────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg  ┆ cyl ┆ disp  ┆ hp    ┆ ... ┆ vs  ┆ am  ┆ gear ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ --- ┆ ---   ┆ ---   ┆     ┆ --- ┆ --- ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64 ┆ f64   ┆ f64   ┆     ┆ f64 ┆ f64 ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════╪═══════╪═══════╪═════╪═════╪═════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.4 ┆ 4.0 ┆ 121.0 ┆ 109.0 ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.5 ┆ 4.0 ┆ 120.1 ┆ 97.0  ┆ ... ┆ 1.0 ┆ 0.0 ┆ 3.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 22.8 ┆ 4.0 ┆ 108.0 ┆ 93.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 22.8 ┆ 4.0 ┆ 140.8 ┆ 95.0  ┆ ... ┆ 1.0 ┆ 0.0 ┆ 4.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...  ┆ ... ┆ ...   ┆ ...   ┆ ... ┆ ... ┆ ... ┆ ...  ┆ ...  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 16.4 ┆ 8.0 ┆ 275.8 ┆ 180.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 3.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 17.3 ┆ 8.0 ┆ 275.8 ┆ 180.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 3.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 18.7 ┆ 8.0 ┆ 360.0 ┆ 175.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 19.2 ┆ 8.0 ┆ 400.0 ┆ 175.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────┴───────┴───────┴─────┴─────┴─────┴──────┴──────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"cyl"</span>, <span class='st'>"mpg"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (32, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────┬───────┬───────┬─────┬─────┬─────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg  ┆ cyl ┆ disp  ┆ hp    ┆ ... ┆ vs  ┆ am  ┆ gear ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ --- ┆ ---   ┆ ---   ┆     ┆ --- ┆ --- ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64 ┆ f64   ┆ f64   ┆     ┆ f64 ┆ f64 ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════╪═══════╪═══════╪═════╪═════╪═════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.4 ┆ 4.0 ┆ 121.0 ┆ 109.0 ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.5 ┆ 4.0 ┆ 120.1 ┆ 97.0  ┆ ... ┆ 1.0 ┆ 0.0 ┆ 3.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 22.8 ┆ 4.0 ┆ 108.0 ┆ 93.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 22.8 ┆ 4.0 ┆ 140.8 ┆ 95.0  ┆ ... ┆ 1.0 ┆ 0.0 ┆ 4.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...  ┆ ... ┆ ...   ┆ ...   ┆ ... ┆ ... ┆ ... ┆ ...  ┆ ...  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 16.4 ┆ 8.0 ┆ 275.8 ┆ 180.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 3.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 17.3 ┆ 8.0 ┆ 275.8 ┆ 180.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 3.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 18.7 ┆ 8.0 ┆ 360.0 ┆ 175.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 19.2 ┆ 8.0 ┆ 400.0 ┆ 175.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────┴───────┴───────┴─────┴─────┴─────┴──────┴──────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"cyl"</span>, <span class='st'>"mpg"</span><span class='op'>)</span>, descending <span class='op'>=</span> <span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (32, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────┬───────┬───────┬─────┬─────┬─────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg  ┆ cyl ┆ disp  ┆ hp    ┆ ... ┆ vs  ┆ am  ┆ gear ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ --- ┆ ---   ┆ ---   ┆     ┆ --- ┆ --- ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64 ┆ f64   ┆ f64   ┆     ┆ f64 ┆ f64 ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════╪═══════╪═══════╪═════╪═════╪═════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 19.2 ┆ 8.0 ┆ 400.0 ┆ 175.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 18.7 ┆ 8.0 ┆ 360.0 ┆ 175.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 17.3 ┆ 8.0 ┆ 275.8 ┆ 180.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 3.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 16.4 ┆ 8.0 ┆ 275.8 ┆ 180.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 3.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...  ┆ ... ┆ ...   ┆ ...   ┆ ... ┆ ... ┆ ... ┆ ...  ┆ ...  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 22.8 ┆ 4.0 ┆ 108.0 ┆ 93.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 22.8 ┆ 4.0 ┆ 140.8 ┆ 95.0  ┆ ... ┆ 1.0 ┆ 0.0 ┆ 4.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.5 ┆ 4.0 ┆ 120.1 ┆ 97.0  ┆ ... ┆ 1.0 ┆ 0.0 ┆ 3.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.4 ┆ 4.0 ┆ 121.0 ┆ 109.0 ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────┴───────┴───────┴─────┴─────┴─────┴──────┴──────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"cyl"</span>, <span class='st'>"mpg"</span><span class='op'>)</span>, descending <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>, <span class='cn'>FALSE</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (32, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────┬───────┬───────┬─────┬─────┬─────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg  ┆ cyl ┆ disp  ┆ hp    ┆ ... ┆ vs  ┆ am  ┆ gear ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ --- ┆ ---   ┆ ---   ┆     ┆ --- ┆ --- ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64 ┆ f64   ┆ f64   ┆     ┆ f64 ┆ f64 ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════╪═══════╪═══════╪═════╪═════╪═════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 10.4 ┆ 8.0 ┆ 472.0 ┆ 205.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 10.4 ┆ 8.0 ┆ 460.0 ┆ 215.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 13.3 ┆ 8.0 ┆ 350.0 ┆ 245.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 14.3 ┆ 8.0 ┆ 360.0 ┆ 245.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...  ┆ ... ┆ ...   ┆ ...   ┆ ... ┆ ... ┆ ... ┆ ...  ┆ ...  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 30.4 ┆ 4.0 ┆ 75.7  ┆ 52.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 30.4 ┆ 4.0 ┆ 95.1  ┆ 113.0 ┆ ... ┆ 1.0 ┆ 1.0 ┆ 5.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 32.4 ┆ 4.0 ┆ 78.7  ┆ 66.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 33.9 ┆ 4.0 ┆ 71.1  ┆ 65.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────┴───────┴───────┴─────┴─────┴─────┴──────┴──────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"cyl"</span><span class='op'>)</span>, <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"mpg"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (32, 11)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────┬───────┬───────┬─────┬─────┬─────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mpg  ┆ cyl ┆ disp  ┆ hp    ┆ ... ┆ vs  ┆ am  ┆ gear ┆ carb │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ --- ┆ ---   ┆ ---   ┆     ┆ --- ┆ --- ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64 ┆ f64   ┆ f64   ┆     ┆ f64 ┆ f64 ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════╪═══════╪═══════╪═════╪═════╪═════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.4 ┆ 4.0 ┆ 121.0 ┆ 109.0 ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 21.5 ┆ 4.0 ┆ 120.1 ┆ 97.0  ┆ ... ┆ 1.0 ┆ 0.0 ┆ 3.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 22.8 ┆ 4.0 ┆ 108.0 ┆ 93.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 22.8 ┆ 4.0 ┆ 140.8 ┆ 95.0  ┆ ... ┆ 1.0 ┆ 0.0 ┆ 4.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...  ┆ ... ┆ ...   ┆ ...   ┆ ... ┆ ... ┆ ... ┆ ...  ┆ ...  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 16.4 ┆ 8.0 ┆ 275.8 ┆ 180.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 3.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 17.3 ┆ 8.0 ┆ 275.8 ┆ 180.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 3.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 18.7 ┆ 8.0 ┆ 360.0 ┆ 175.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 19.2 ┆ 8.0 ┆ 400.0 ┆ 175.0 ┆ ... ┆ 0.0 ┆ 0.0 ┆ 3.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────┴───────┴───────┴─────┴─────┴─────┴──────┴──────┘</span>
 </code></pre>