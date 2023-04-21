# join DataFrame with other DataFrame

```r
DataFrame_join(
  other,
  left_on = NULL,
  right_on = NULL,
  on = NULL,
  how = c("inner", "left", "outer", "semi", "anti", "cross"),
  suffix = "_right",
  allow_parallel = TRUE,
  force_parallel = FALSE
)
```

## Arguments

- `other`: DataFrame
- `left_on`: names of columns in self LazyFrame, order should match. Type, see on param.
- `right_on`: names of columns in other LazyFrame, order should match. Type, see on param.
- `on`: named columns as char vector of named columns, or list of expressions and/or strings.
- `how`: a string selecting one of the following methods: inner, left, outer, semi, anti, cross
- `suffix`: name to added right table
- `allow_parallel`: bool
- `force_parallel`: bool

## Returns

DataFrame

join DataFrame with other DataFrame

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>df1</span> <span class='op'>&lt;-</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>key<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>,payload<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>'f'</span>,<span class='st'>'i'</span>,<span class='cn'>NA</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (3, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ key ┆ payload │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ str     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ f       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ i       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   ┆ null    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────────┘</span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>df2</span> <span class='op'>&lt;-</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>key<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>3L</span>,<span class='fl'>4L</span>,<span class='fl'>5L</span>,<span class='cn'>NA_integer_</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ key  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┘</span>
<span class='r-in'><span><span class='va'>df1</span><span class='op'>$</span><span class='fu'>join</span><span class='op'>(</span>other <span class='op'>=</span> <span class='va'>df2</span>,on <span class='op'>=</span> <span class='st'>'key'</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ key ┆ payload │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ str     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   ┆ null    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────────┘</span>
 </code></pre>