data

# Compute the exponential, element-wise.

## Format

a method

```r
Expr_exp
```

## Returns

Expr

Compute the exponential, element-wise.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>log10123</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/warning.html'>suppressWarnings</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/Log.html'>log</a></span><span class='op'>(</span><span class='op'>-</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/all.equal.html'>all.equal</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a <span class='op'>=</span> <span class='va'>log10123</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>exp</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>as_data_frame</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='va'>a</span>,</span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/Log.html'>exp</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>)</span><span class='op'>^</span><span class='va'>log10123</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
 </code></pre>