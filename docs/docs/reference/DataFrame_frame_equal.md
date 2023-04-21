# Drop in place

```r
DataFrame_frame_equal(other)
```

## Arguments

- `other`: DataFrame to compare with.

## Returns

bool

Check if DataFrame is equal to other.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>dat1</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>dat2</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>dat3</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>dat1</span><span class='op'>$</span><span class='fu'>frame_equal</span><span class='op'>(</span><span class='va'>dat2</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
<span class='r-in'><span><span class='va'>dat1</span><span class='op'>$</span><span class='fu'>frame_equal</span><span class='op'>(</span><span class='va'>dat3</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
 </code></pre>