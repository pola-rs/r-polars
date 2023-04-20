# rename fields

## Arguments

- `names`: char vec or list of strings given in the same order as the struct's fields. Providing fewer names will drop the latter fields. Providing too many names is ignored.

## Returns

Expr: struct-series with new names for the fields

Rename the fields of the struct. By default base 2.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  aaa <span class='op'>=</span> <span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,</span></span>
<span class='r-in'><span>  bbb <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"ab"</span>, <span class='st'>"cd"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  ccc <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>, <span class='cn'>NA</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  ddd <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>, <span class='fl'>3L</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>struct</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"struct_col"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"struct_col"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>struct</span><span class='op'>$</span><span class='fu'>rename_fields</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"www"</span>, <span class='st'>"xxx"</span>, <span class='st'>"yyy"</span>, <span class='st'>"zzz"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>unnest</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┬──────┬───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ www ┆ xxx ┆ yyy  ┆ zzz       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- ┆ ---  ┆ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ str ┆ bool ┆ list[i32] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╪══════╪═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ ab  ┆ true ┆ [1, 2]    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ cd  ┆ null ┆ [3]       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┴──────┴───────────┘</span>
 </code></pre>