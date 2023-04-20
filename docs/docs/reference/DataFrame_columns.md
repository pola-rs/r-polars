# get/set columns (the names columns)

```r
RField_datatype()

DataFrame_columns()
```

## Returns

char vec of column names

char vec of column names

get/set column names of DataFrame object

get/set column names of DataFrame object

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#get values</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='va'>columns</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width"  "Species"     </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#set + get values</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='va'>columns</span> <span class='op'>=</span> <span class='va'>letters</span><span class='op'>[</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>]</span> <span class='co'>#&lt;- is fine too</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='va'>columns</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "a" "b" "c" "d" "e"</span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#get values</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='va'>columns</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width"  "Species"     </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#set + get values</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='va'>columns</span> <span class='op'>=</span> <span class='va'>letters</span><span class='op'>[</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>]</span> <span class='co'>#&lt;- is fine too</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='va'>columns</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "a" "b" "c" "d" "e"</span>
 </code></pre>