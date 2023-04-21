# Fill NaN

```r
LazyFrame_fill_nan(fill_value)
```

## Arguments

- `fill_value`: Value to fill NaN with.

## Returns

LazyFrame

Fill floating point NaN values by an Expression evaluation.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>        a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1.5</span>, <span class='fl'>2</span>, <span class='cn'>NaN</span>, <span class='fl'>4</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>        b <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1.5</span>, <span class='cn'>NaN</span>, <span class='cn'>NaN</span>, <span class='fl'>4</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>fill_nan</span><span class='op'>(</span><span class='fl'>99</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (4, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a    ┆ b    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.5  ┆ 1.5  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2.0  ┆ 99.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 99.0 ┆ 99.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.0  ┆ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴──────┘</span>
 </code></pre>