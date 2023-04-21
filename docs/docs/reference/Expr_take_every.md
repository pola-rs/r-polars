# Take every n'th element

## Format

a method

```r
Expr_take_every(n)
```

## Arguments

- `n`: positive integerish value

## Returns

Expr

Take every nth value in the Series and return as a new Series.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='fl'>0</span><span class='op'>:</span><span class='fl'>24</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>take_every</span><span class='op'>(</span><span class='fl'>6</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 12  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 18  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 24  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
 </code></pre>