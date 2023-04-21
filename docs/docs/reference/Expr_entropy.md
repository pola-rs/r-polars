# Entropy

```r
Expr_entropy(base = base::exp(1), normalize = TRUE)
```

## Arguments

- `base`: Given exponential base, defaults to `e`
- `normalize`: Normalize pk if it doesn't sum to 1.

## Returns

Expr

Computes the entropy. Uses the formula `-sum(pk * log(pk))` where `pk` are discrete probabilities. Return Null if input is not values

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a"</span>,<span class='st'>"b"</span>,<span class='st'>"b"</span>,<span class='st'>"c"</span>,<span class='st'>"c"</span>,<span class='st'>"c"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>unique_counts</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>entropy</span><span class='op'>(</span>base<span class='op'>=</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (1, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.459148 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────┘</span>
 </code></pre>