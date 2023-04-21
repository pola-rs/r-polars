# round

## Format

a method

```r
Expr_round(decimals)
```

## Arguments

- `decimals`: integer Number of decimals to round by.

## Returns

Expr

Round underlying floating point data by `decimals` digits.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>0.33</span>, <span class='fl'>0.5</span>, <span class='fl'>1.02</span>, <span class='fl'>1.5</span>, <span class='cn'>NaN</span> , <span class='cn'>NA</span>, <span class='cn'>Inf</span>, <span class='op'>-</span><span class='cn'>Inf</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>round</span><span class='op'>(</span><span class='fl'>0</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (8, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ NaN  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ inf  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ -inf │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┘</span>
 </code></pre>