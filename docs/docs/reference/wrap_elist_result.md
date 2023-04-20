# wrap_elist_result

```r
wrap_elist_result(elist, str_to_lit = TRUE)
```

## Arguments

- `elist`: a list Expr or any R object Into  (passable to pl$lit)

## Returns

Expr

make sure all elementsof a list is wrapped as Expr Capture any conversion error in the result

## Details

Used internally to ensure an object is a list of expression The output is wrapped in a result, which can contain an ok or err value.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='fu'>polars</span><span class='fu'>:::</span><span class='fu'><a href='https://rdrr.io/pkg/polars/man/wrap_elist_result.html'>wrap_elist_result</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>42</span><span class='op'>)</span>,<span class='fl'>42</span>,<span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $ok</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $ok[[1]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: 42f64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $ok[[2]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: 42f64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $ok[[3]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: Series</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $err</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> attr(,"class")</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "extendr_result"</span>
 </code></pre>