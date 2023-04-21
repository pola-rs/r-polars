# Simple viewer of an R object based on str()

```r
str_string(x, collapse = " ")
```

## Arguments

- `x`: object to view.
- `collapse`: word to glue possible multilines with

## Returns

string

Simple viewer of an R object based on str()

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='fu'>polars</span><span class='fu'>:::</span><span class='fu'><a href='https://rdrr.io/pkg/polars/man/str_string.html'>str_string</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='fl'>42</span>,<span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='fl'>2</span>,<span class='fl'>3</span>,<span class='cn'>NA</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "List of 2  $ a: num 42  $  : num [1:4] 1 2 3 NA"</span>
 </code></pre>