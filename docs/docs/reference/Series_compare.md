# Compare Series

```r
Series_compare(other, op)

## S3 method for class 'Series'
s1 == s2

## S3 method for class 'Series'
s1 != s2

## S3 method for class 'Series'
s1 < s2

## S3 method for class 'Series'
s1 > s2

## S3 method for class 'Series'
s1 <= s2

## S3 method for class 'Series'
s1 >= s2
```

## Arguments

- `other`: A Series or something a Series can be created from
- `op`: the chosen operator a String either: 'equal', 'not_equal', 'lt', 'gt', 'lt_eq' or 'gt_eq'
- `s1`: lhs Series
- `s2`: rhs Series or any into Series

## Returns

Series

compare two Series

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span> <span class='op'>==</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>,<span class='cn'>NA_integer_</span>,<span class='fl'>10L</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (5,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [bool]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	true</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	true</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	true</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	false</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	false</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>