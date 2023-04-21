# field

## Arguments

- `name`: string, the Name of the struct field to retrieve.

## Returns

Expr: Series of same and name selected field.

Retrieve a `Struct` field as a new Series. By default base 2.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>     aaa <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>, <span class='fl'>2</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>     bbb <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"ab"</span>, <span class='st'>"cd"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>     ccc <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>, <span class='cn'>NA</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>     ddd <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>, <span class='fl'>2</span><span class='op'>)</span>, <span class='fl'>3</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>struct</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"struct_col"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='co'>#struct field into a new Series</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"struct_col"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>struct</span><span class='op'>$</span><span class='fu'>field</span><span class='op'>(</span><span class='st'>"bbb"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"struct_col"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>struct</span><span class='op'>$</span><span class='fu'>field</span><span class='op'>(</span><span class='st'>"ddd"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bbb ┆ ddd        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str ┆ list[f64]  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ab  ┆ [1.0, 2.0] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cd  ┆ [3.0]      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴────────────┘</span>
 </code></pre>