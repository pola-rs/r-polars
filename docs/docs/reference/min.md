# min across expressions / literals / Series

## Arguments

- `...`: is a: If one arg:
    
     * Series or Expr, same as `column$sum()`
     * string, same as `pl$col(column)$sum()`
     * numeric, same as `pl$lit(column)$sum()`
     * list of strings(column names) or exprressions to add up as expr1 + expr2 + expr3 + ...
    
    If several args, then wrapped in a list and handled as above.

## Returns

Expr

Folds the expressions from left to right, keeping the first non-null value.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  a <span class='op'>=</span> <span class='cn'>NA_real_</span>,</span></span>
<span class='r-in'><span>  b <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>2</span><span class='op'>:</span><span class='fl'>1</span>,<span class='cn'>NA_real_</span>,<span class='cn'>NA_real_</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  c <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>,<span class='cn'>NA_real_</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  d <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,<span class='cn'>NA_real_</span>,<span class='op'>-</span><span class='cn'>Inf</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='co'>#use min to get first non Null value for each row, otherwise insert 99.9</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>with_column</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>min</span><span class='op'>(</span><span class='st'>"a"</span>, <span class='st'>"b"</span>, <span class='st'>"c"</span>, <span class='fl'>99.9</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"d"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (4, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬──────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a    ┆ b    ┆ c    ┆ d    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---  ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64  ┆ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪══════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ 2.0  ┆ 1.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ 1.0  ┆ 2.0  ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null ┆ 3.0  ┆ 3.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null ┆ null ┆ 99.9 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴──────┴──────┴──────┘</span>
 </code></pre>