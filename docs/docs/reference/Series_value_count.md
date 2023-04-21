# Value Counts as DataFrame

```r
Series_value_counts(sorted = TRUE, multithreaded = FALSE)
```

## Arguments

- `sorted`: bool, default TRUE: sort table by value; FALSE: random
- `multithreaded`: bool, default FALSE, process multithreaded. Likely faster to have TRUE for a big Series. If called within an already multithreaded context such calling apply on a GroupBy with many groups, then likely slightly faster to leave FALSE.

## Returns

DataFrame

Value Counts as DataFrame

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>$</span><span class='va'>Species</span>,<span class='st'>"flower species"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>value_counts</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────────┬────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ flower species ┆ counts │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---            ┆ ---    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cat            ┆ u32    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════════╪════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ setosa         ┆ 50     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ versicolor     ┆ 50     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ virginica      ┆ 50     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────────┴────────┘</span>
 </code></pre>