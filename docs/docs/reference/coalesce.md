# Coalesce

## Arguments

- `...`: is a: If one arg:
    
     * Series or Expr, same as `column$sum()`
     * string, same as `pl$col(column)$sum()`
     * numeric, same as `pl$lit(column)$sum()`
     * list of strings(column names) or exprressions to add up as expr1 + expr2 + expr3 + ...
    
    If several args, then wrapped in a list and handled as above.
- `exprs`: list of Expr or Series or strings or a mix, or a char vector

## Returns

Expr

Expr

Folds the expressions from left to right, keeping the first non-null value.

Folds the expressions from left to right, keeping the first non-null value.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  a <span class='op'>=</span> <span class='cn'>NA_real_</span>,</span></span>
<span class='r-in'><span>  b <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,<span class='cn'>NA_real_</span>,<span class='cn'>NA_real_</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  c <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>,<span class='cn'>NA_real_</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='co'>#use coalesce to get first non Null value for each row, otherwise insert 99.9</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>coalesce</span><span class='op'>(</span><span class='st'>"a"</span>, <span class='st'>"b"</span>, <span class='st'>"c"</span>, <span class='fl'>99.9</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"d"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (4, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬──────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a    ┆ b    ┆ c    ┆ d    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---  ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64  ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪══════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ 1.0  ┆ 1.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ 2.0  ┆ 2.0  ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null ┆ 3.0  ┆ 3.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null ┆ null ┆ 99.9 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴──────┴──────┴──────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#Create lagged columns and collect them into a list. This mimics a rolling window.</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>A <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='fl'>2</span>,<span class='fl'>9</span>,<span class='fl'>2</span>,<span class='fl'>13</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/lapply.html'>lapply</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='fl'>0</span><span class='op'>:</span><span class='fl'>2</span>,</span></span>
<span class='r-in'><span>  \<span class='op'>(</span><span class='va'>i</span><span class='op'>)</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"A"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>shift</span><span class='op'>(</span><span class='va'>i</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='op'>(</span><span class='st'>"A_lag_"</span>,<span class='va'>i</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>concat_list</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/lapply.html'>lapply</a></span><span class='op'>(</span><span class='fl'>2</span><span class='op'>:</span><span class='fl'>0</span>,\<span class='op'>(</span><span class='va'>i</span><span class='op'>)</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='op'>(</span><span class='st'>"A_lag_"</span>,<span class='va'>i</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='st'>"A_rolling"</span></span></span>
<span class='r-in'><span> <span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ A_rolling         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list[f64]         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [null, null, 1.0] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [null, 1.0, 2.0]  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [1.0, 2.0, 9.0]   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [2.0, 9.0, 2.0]   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [9.0, 2.0, 13.0]  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#concat Expr a Series and an R obejct</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>concat_list</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>5</span><span class='op'>:</span><span class='fl'>1</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='op'>(</span><span class='fl'>0L</span>,<span class='fl'>5</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"alice"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (5,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'alice' [list[i32]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	[1, 5, 0]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	[2, 4, 0]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	[3, 3, 0]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	[4, 2, 0]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	[5, 1, 0]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>