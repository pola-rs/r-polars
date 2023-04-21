# Clone a DataFrame

*Source: [R/dataframe__frame.R](https://github.com/pola-rs/r-polars/tree/main/R/dataframe__frame.R)*

```r
DataFrame_clone()
```

## Returns

DataFrame

Rarely useful as DataFrame is nearly 100% immutable Any modification of a DataFrame would lead to a clone anyways.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df1</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span>;</span></span>
<span class='r-in'><span><span class='va'>df2</span> <span class='op'>=</span>  <span class='va'>df1</span><span class='op'>$</span><span class='fu'>clone</span><span class='op'>(</span><span class='op'>)</span>;</span></span>
<span class='r-in'><span><span class='va'>df3</span> <span class='op'>=</span> <span class='va'>df1</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>mem_address</span><span class='op'>(</span><span class='va'>df1</span><span class='op'>)</span> <span class='op'>!=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>mem_address</span><span class='op'>(</span><span class='va'>df2</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>mem_address</span><span class='op'>(</span><span class='va'>df1</span><span class='op'>)</span> <span class='op'>==</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>mem_address</span><span class='op'>(</span><span class='va'>df3</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
 </code></pre>