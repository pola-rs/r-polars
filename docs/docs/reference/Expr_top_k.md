# Top k values

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

## Format

a method

```r
Expr_top_k(k, reverse = FALSE)
```

## Arguments

- `k`: numeric k top values to get
- `reverse`: bool if true then k smallest values

## Returns

Expr

Return the `k` largest elements. If 'reverse=True` the smallest elements will be given.

## Details

This has time complexity: ` O(n + k \\log{}n - \frac{k}{2}) `

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>6</span>, <span class='fl'>1</span>, <span class='fl'>0</span>, <span class='cn'>NA</span>, <span class='cn'>Inf</span>, <span class='cn'>NaN</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>top_k</span><span class='op'>(</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ NaN │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ inf │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
 </code></pre>