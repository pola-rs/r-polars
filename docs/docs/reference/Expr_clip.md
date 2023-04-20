# Clip

```r
Expr_clip(min, max)

Expr_clip_min(min)

Expr_clip_max(max)
```

## Arguments

- `min`: Minimum Value, ints and floats or any literal expression of ints and floats
- `max`: Maximum Value, ints and floats or any literal expression of ints and floats

## Returns

Expr

Clip (limit) the values in an array to a `min` and `max` boundary.

## Details

Only works for numerical types. If you want to clip other dtypes, consider writing a "when, then, otherwise" expression. See :func:`when` for more information.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>foo <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='op'>-</span><span class='fl'>50L</span>, <span class='fl'>5L</span>, <span class='cn'>NA_integer_</span>,<span class='fl'>50L</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"foo"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>clip</span><span class='op'>(</span><span class='fl'>1L</span>,<span class='fl'>10L</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"foo_clipped"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo  ┆ foo_clipped │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32  ┆ i32         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ -50  ┆ 1           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5    ┆ 5           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 50   ┆ 10          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────────────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"foo"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>clip_min</span><span class='op'>(</span><span class='fl'>1L</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"foo_clipped"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo  ┆ foo_clipped │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32  ┆ i32         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ -50  ┆ 1           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5    ┆ 5           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 50   ┆ 50          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────────────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"foo"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>clip_max</span><span class='op'>(</span><span class='fl'>10L</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"foo_clipped"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo  ┆ foo_clipped │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32  ┆ i32         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ -50  ┆ -50         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5    ┆ 5           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 50   ┆ 10          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────────────┘</span>
 </code></pre>