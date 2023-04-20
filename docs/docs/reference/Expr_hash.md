# hash

```r
Expr_hash(seed = 0, seed_1 = NULL, seed_2 = NULL, seed_3 = NULL)
```

## Arguments

- `seed`: Random seed parameter. Defaults to 0.
- `seed_1`: Random seed parameter. Defaults to arg seed.
- `seed_2`: Random seed parameter. Defaults to arg seed.
- `seed_3`: Random seed parameter. Defaults to arg seed. The column will be coerced to UInt32. Give this dtype to make the coercion a no-op.

## Returns

Expr

Hash the elements in the selection. The hash value is of type `UInt64`.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>head</span><span class='op'>(</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>hash</span><span class='op'>(</span><span class='fl'>1234</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_list</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Sepal.Length</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "8787545805499047296" "3480667128160896"   </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Sepal.Width</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "10016005571271983104" "12826251738751172608"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Petal.Length</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "11417647987883416960" "11417647987883416960"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Petal.Width</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "15099546618074063488" "15099546618074063488"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Species</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "0" "0"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>