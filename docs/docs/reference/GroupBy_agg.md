# GroupBy Aggregate

```r
GroupBy_agg(...)
```

## Arguments

- `...`: exprs to aggregate

## Returns

aggregated DataFrame

Aggregatete a DataFrame over a groupby

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>    foo <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"one"</span>, <span class='st'>"two"</span>, <span class='st'>"two"</span>, <span class='st'>"one"</span>, <span class='st'>"two"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    bar <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>5</span>, <span class='fl'>3</span>, <span class='fl'>2</span>, <span class='fl'>4</span>, <span class='fl'>1</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>groupby</span><span class='op'>(</span></span></span>
<span class='r-in'><span><span class='st'>"foo"</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>agg</span><span class='op'>(</span></span></span>
<span class='r-in'><span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"bar"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"bar_sum"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"bar"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>mean</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"bar_tail_sum"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────────┬──────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo ┆ bar_sum ┆ bar_tail_sum │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---     ┆ ---          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str ┆ f64     ┆ f64          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════════╪══════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ one ┆ 9.0     ┆ 4.5          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ two ┆ 6.0     ┆ 2.0          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────────┴──────────────┘</span>
 </code></pre>