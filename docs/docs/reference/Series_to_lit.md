# Series to Literal

*Source: [R/series__series.R](https://github.com/pola-rs/r-polars/tree/main/R/series__series.R)*

```r
Series_to_lit()
```

## Returns

Expr

convert Series to literal to perform modification and return

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>1</span>, <span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>, <span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>, <span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='op'>$</span><span class='fu'>print</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='op'>$</span><span class='fu'>to_lit</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>lengths</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>Int8</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (4,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [list[i32]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	[1]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	[1, 2]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	[1, 2, 3]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	[1, 2, ... 4]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [i8]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	10</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>