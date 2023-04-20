data

# Clone a Series

## Format

An object of class `character` of length 1.

```r
Series_clone
```

## Returns

Series

Rarely useful as Series are nearly 100% immutable Any modification of a Series should lead to a clone anyways.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>s1</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span>;</span></span>
<span class='r-in'><span><span class='va'>s2</span> <span class='op'>=</span>  <span class='va'>s1</span><span class='op'>$</span><span class='fu'>clone</span><span class='op'>(</span><span class='op'>)</span>;</span></span>
<span class='r-in'><span><span class='va'>s3</span> <span class='op'>=</span> <span class='va'>s1</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>mem_address</span><span class='op'>(</span><span class='va'>s1</span><span class='op'>)</span> <span class='op'>!=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>mem_address</span><span class='op'>(</span><span class='va'>s2</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>mem_address</span><span class='op'>(</span><span class='va'>s1</span><span class='op'>)</span> <span class='op'>==</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>mem_address</span><span class='op'>(</span><span class='va'>s3</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
 </code></pre>