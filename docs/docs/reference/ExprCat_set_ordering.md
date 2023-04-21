# Set Ordering

## Arguments

- `ordering`: string either 'physical' or 'lexical'
    
     * 'physical' -> Use the physical representation of the categories to determine the order (default).
     * 'lexical' -> Use the string values to determine the ordering.

## Returns

bool: TRUE if equal

Determine how this categorical series should be sorted.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  cats <span class='op'>=</span>  <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"z"</span>, <span class='st'>"z"</span>, <span class='st'>"k"</span>, <span class='st'>"a"</span>, <span class='st'>"b"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  vals <span class='op'>=</span>  <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>3</span>, <span class='fl'>1</span>, <span class='fl'>2</span>, <span class='fl'>2</span>, <span class='fl'>3</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"cats"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Categorical</span><span class='op'>)</span><span class='op'>$</span><span class='va'>cat</span><span class='op'>$</span><span class='fu'>set_ordering</span><span class='op'>(</span><span class='st'>"physical"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (5, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cats ┆ vals │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cat  ┆ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ z    ┆ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ z    ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ k    ┆ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a    ┆ 3.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ b    ┆ 3.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴──────┘</span>
 </code></pre>