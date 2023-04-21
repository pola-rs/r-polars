# reinterpret bits

```r
Expr_reinterpret(signed = TRUE)
```

## Arguments

- `signed`: bool reinterpret into Int64 else UInt64

## Returns

Expr

Reinterpret the underlying bits as a signed/unsigned integer. This operation is only allowed for 64bit integers. For lower bits integers, you can safely use that cast operation.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>head</span><span class='op'>(</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>hash</span><span class='op'>(</span><span class='fl'>1</span>,<span class='fl'>2</span>,<span class='fl'>3</span>,<span class='fl'>4</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>reinterpret</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>as_data_frame</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           Sepal.Length          Sepal.Width         Petal.Length         Petal.Width Species</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 1  1175582113423737064  7264306198948610048 -7761811347093012248 -236581591116988648       0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 2 -7705801573110956264 -1306043891937443840 -7761811347093012248 -236581591116988648       0</span>
 </code></pre>