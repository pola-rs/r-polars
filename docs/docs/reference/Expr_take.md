# Take values by index.

## Format

a method

```r
Expr_take(indices)
```

## Arguments

- `indices`: R scalar/vector or Series, or Expr that leads to a UInt32 dtyped Series.

## Returns

Expr

Take values by index.

## Details

similar to R indexing syntax e.g. `letters[c(1,3,5)]`, however as an expression, not as eager computation exceeding

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>0</span><span class='op'>:</span><span class='fl'>10</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>take</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='fl'>8</span>,<span class='fl'>0</span>,<span class='fl'>7</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 8   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 7   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
 </code></pre>