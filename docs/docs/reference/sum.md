# sum across expressions / literals / Series

## Arguments

- `...`: is a: If one arg:
    
     * Series or Expr, same as `column$sum()`
     * string, same as `pl$col(column)$sum()`
     * numeric, same as `pl$lit(column)$sum()`
     * list of strings(column names) or exprressions to add up as expr1 + expr2 + expr3 + ...
    
    If several args, then wrapped in a list and handled as above.

## Returns

Expr

syntactic sugar for starting a expression with sum

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#column as string</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='st'>"Petal.Width"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Petal.Width │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 179.9       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#column as Expr (prefer pl$col("Petal.Width")$sum())</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Petal.Width"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Petal.Width │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 179.9       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#column as numeric</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 15  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#column as list</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,b<span class='op'>=</span><span class='fl'>3</span><span class='op'>:</span><span class='fl'>4</span>,c<span class='op'>=</span><span class='fl'>5</span><span class='op'>:</span><span class='fl'>6</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='st'>"a"</span>,<span class='st'>"c"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┬─────┬─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   ┆ b   ┆ c   ┆ sum │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- ┆ --- ┆ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ i32 ┆ i32 ┆ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╪═════╪═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ 3   ┆ 5   ┆ 6   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ 4   ┆ 6   ┆ 8   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┴─────┴─────┘</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,b<span class='op'>=</span><span class='fl'>3</span><span class='op'>:</span><span class='fl'>4</span>,c<span class='op'>=</span><span class='fl'>5</span><span class='op'>:</span><span class='fl'>6</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='st'>"a"</span>,<span class='st'>"c"</span>, <span class='fl'>42L</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┬─────┬─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   ┆ b   ┆ c   ┆ sum │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- ┆ --- ┆ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ i32 ┆ i32 ┆ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╪═════╪═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ 3   ┆ 5   ┆ 48  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ 4   ┆ 6   ┆ 50  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┴─────┴─────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#three eqivalent lines</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,b<span class='op'>=</span><span class='fl'>3</span><span class='op'>:</span><span class='fl'>4</span>,c<span class='op'>=</span><span class='fl'>5</span><span class='op'>:</span><span class='fl'>6</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='st'>"a"</span>,<span class='st'>"c"</span>, <span class='va'>pl</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='st'>"a"</span>,<span class='st'>"b"</span>,<span class='st'>"c"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┬─────┬─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   ┆ b   ┆ c   ┆ sum │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- ┆ --- ┆ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ i32 ┆ i32 ┆ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╪═════╪═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ 3   ┆ 5   ┆ 15  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ 4   ┆ 6   ┆ 20  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┴─────┴─────┘</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,b<span class='op'>=</span><span class='fl'>3</span><span class='op'>:</span><span class='fl'>4</span>,c<span class='op'>=</span><span class='fl'>5</span><span class='op'>:</span><span class='fl'>6</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>+</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"b"</span><span class='op'>)</span>,<span class='st'>"c"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┬─────┬─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   ┆ b   ┆ c   ┆ sum │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- ┆ --- ┆ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ i32 ┆ i32 ┆ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╪═════╪═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ 3   ┆ 5   ┆ 9   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ 4   ┆ 6   ┆ 12  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┴─────┴─────┘</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,b<span class='op'>=</span><span class='fl'>3</span><span class='op'>:</span><span class='fl'>4</span>,c<span class='op'>=</span><span class='fl'>5</span><span class='op'>:</span><span class='fl'>6</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='st'>"*"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┬─────┬─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   ┆ b   ┆ c   ┆ sum │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- ┆ --- ┆ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ i32 ┆ i32 ┆ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╪═════╪═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ 3   ┆ 5   ┆ 9   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ 4   ┆ 6   ┆ 12  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┴─────┴─────┘</span>
 </code></pre>