# GroupBy Var

```r
GroupBy_var()
```

## Returns

aggregated DataFrame

Reduce the groups to the variance value.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>        a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>, <span class='fl'>2</span>, <span class='fl'>2</span>, <span class='fl'>3</span>, <span class='fl'>4</span>, <span class='fl'>5</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>        b <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>0.5</span>, <span class='fl'>0.5</span>, <span class='fl'>4</span>, <span class='fl'>10</span>, <span class='fl'>13</span>, <span class='fl'>14</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>        c <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>, <span class='cn'>TRUE</span>, <span class='cn'>TRUE</span>, <span class='cn'>FALSE</span>, <span class='cn'>FALSE</span>, <span class='cn'>TRUE</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>        d <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"Apple"</span>, <span class='st'>"Orange"</span>, <span class='st'>"Apple"</span>, <span class='st'>"Apple"</span>, <span class='st'>"Banana"</span>, <span class='st'>"Banana"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>groupby</span><span class='op'>(</span><span class='st'>"d"</span>, maintain_order<span class='op'>=</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>var</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────┬─────┬───────────┬──────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ d      ┆ a   ┆ b         ┆ c        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---    ┆ --- ┆ ---       ┆ ---      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str    ┆ f64 ┆ f64       ┆ f64      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════╪═════╪═══════════╪══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Apple  ┆ 1.0 ┆ 23.083333 ┆ 0.333333 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Orange ┆ 0.0 ┆ 0.0       ┆ 0.0      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Banana ┆ 0.5 ┆ 0.5       ┆ 0.5      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────┴─────┴───────────┴──────────┘</span>
 </code></pre>