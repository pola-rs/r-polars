# div Series

*Source: [R/series__series.R](https://github.com/pola-rs/r-polars/tree/main/R/series__series.R)*

```r
Series_div(other)

## S3 method for class 'Series'
s1 / s2
```

## Arguments

- `other`: Series or into Series
- `s1`: lhs Series
- `s2`: rhs Series or any into Series

## Returns

Series

Series arithmetics

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>div</span><span class='op'>(</span><span class='fl'>11</span><span class='op'>:</span><span class='fl'>13</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (3,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [i32]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>div</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>11</span><span class='op'>:</span><span class='fl'>13</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (3,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [i32]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>div</span><span class='op'>(</span><span class='fl'>1L</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (3,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [i32]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	3</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='fl'>2L</span> <span class='op'>/</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (3,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [i32]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span> <span class='op'>/</span> <span class='fl'>2L</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (3,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [i32]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>