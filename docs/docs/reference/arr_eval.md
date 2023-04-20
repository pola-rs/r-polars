# eval sublists (kinda like lapply)

## Format

function

## Arguments

- `Expr`: Expression to run. Note that you can select an element with `pl$first()`, or `pl$col()`
- `parallel`: bool Run all expression parallel. Don't activate this blindly. Parallelism is worth it if there is enough work to do per thread. This likely should not be use in the groupby context, because we already parallel execution per group

## Returns

Expr

Run any polars expression against the lists' elements.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='fl'>8</span>,<span class='fl'>3</span><span class='op'>)</span>, b <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>4</span>,<span class='fl'>5</span>,<span class='fl'>2</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>Int64</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>concat_list</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a"</span>,<span class='st'>"b"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>eval</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>element</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>rank</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"rank"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (3, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────┬─────┬────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ new_column ┆ b   ┆ rank       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---        ┆ --- ┆ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i64        ┆ i64 ┆ list[f32]  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════╪═════╪════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1          ┆ 4   ┆ [1.0, 2.0] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 8          ┆ 5   ┆ [1.0, 2.0] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3          ┆ 2   ┆ [1.0, 2.0] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────┴─────┴────────────┘</span>
 </code></pre>