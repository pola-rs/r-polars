# GroupBy Max

*Source: [R/groupby.R](https://github.com/pola-rs/r-polars/tree/main/R/groupby.R)*

```r
GroupBy_max()
```

## Returns

aggregated DataFrame

Reduce the groups to the maximum value.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>        a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>, <span class='fl'>2</span>, <span class='fl'>2</span>, <span class='fl'>3</span>, <span class='fl'>4</span>, <span class='fl'>5</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>        b <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>0.5</span>, <span class='fl'>0.5</span>, <span class='fl'>4</span>, <span class='fl'>10</span>, <span class='fl'>13</span>, <span class='fl'>14</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>        c <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>, <span class='cn'>TRUE</span>, <span class='cn'>TRUE</span>, <span class='cn'>FALSE</span>, <span class='cn'>FALSE</span>, <span class='cn'>TRUE</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>        d <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"Apple"</span>, <span class='st'>"Orange"</span>, <span class='st'>"Apple"</span>, <span class='st'>"Apple"</span>, <span class='st'>"Banana"</span>, <span class='st'>"Banana"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>groupby</span><span class='op'>(</span><span class='st'>"d"</span>, maintain_order<span class='op'>=</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>max</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────┬─────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ d      ┆ a   ┆ b    ┆ c    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---    ┆ --- ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str    ┆ f64 ┆ f64  ┆ bool │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════╪═════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Apple  ┆ 3.0 ┆ 10.0 ┆ true │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Orange ┆ 2.0 ┆ 0.5  ┆ true │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Banana ┆ 5.0 ┆ 14.0 ┆ true │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────┴─────┴──────┴──────┘</span>
 </code></pre>