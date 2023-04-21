# Get r vector/list

```r
Series_to_r()

Series_to_r_vector()

Series_to_r_list()
```

## Returns

R list or vector

R vector

R list

return R list (if polars Series is list) or vector (any other polars Series type)

return R vector (implicit unlist)

return R list (implicit as.list)

## Details

Fun fact: Nested polars Series list must have same inner type, e.g. List(List(Int32)) Thus every leaf(non list type) will be placed on the same depth of the tree, and be the same type.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#make polars Series_Utf8</span></span></span>
<span class='r-in'><span><span class='va'>series_vec</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='va'>letters</span><span class='op'>[</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>]</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#Series_non_list</span></span></span>
<span class='r-in'><span><span class='va'>series_vec</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#as vector because Series DataType is not list (is Utf8)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "a" "b" "c"</span>
<span class='r-in'><span><span class='va'>series_vec</span><span class='op'>$</span><span class='fu'>to_r_list</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#implicit call as.list(), convert to list</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[1]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "a"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[2]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "b"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[3]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "c"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span><span class='va'>series_vec</span><span class='op'>$</span><span class='fu'>to_r_vector</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#implicit call unlist(), same as to_r() as already vector</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "a" "b" "c"</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#make nested Series_list of Series_list of Series_Int32</span></span></span>
<span class='r-in'><span><span class='co'>#using Expr syntax because currently more complete translated</span></span></span>
<span class='r-in'><span><span class='va'>series_list</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span>,<span class='cn'>NA_integer_</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>list</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>list</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>append</span><span class='op'>(</span></span></span>
<span class='r-in'><span>    <span class='op'>(</span></span></span>
<span class='r-in'><span>      <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>head</span><span class='op'>(</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>list</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>append</span><span class='op'>(</span></span></span>
<span class='r-in'><span>        <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>tail</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>list</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span>      <span class='op'>)</span></span></span>
<span class='r-in'><span>    <span class='op'>)</span><span class='op'>$</span><span class='fu'>list</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>get_column</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span> <span class='co'># get series from DataFrame</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#Series_list</span></span></span>
<span class='r-in'><span><span class='va'>series_list</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#as list because Series DataType is list</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[1]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[1]][[1]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1]  1  2  3  4  5 NA</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[2]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[2]][[1]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 1 2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[2]][[2]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] NA</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span><span class='va'>series_list</span><span class='op'>$</span><span class='fu'>to_r_list</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#implicit call as.list(), same as to_r() as already list</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[1]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[1]][[1]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1]  1  2  3  4  5 NA</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[2]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[2]][[1]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 1 2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[2]][[2]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] NA</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span><span class='va'>series_list</span><span class='op'>$</span><span class='fu'>to_r_vector</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#implicit call unlist(), append into a vector</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1]  1  2  3  4  5 NA  1  2 NA</span>
<span class='r-in'><span> <span class='co'>#</span></span></span>
<span class='r-in'><span> <span class='co'>#</span></span></span>
 </code></pre>