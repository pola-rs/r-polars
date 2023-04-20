# Index of a sort

## Format

a method

```r
Expr_arg_sort(reverse = FALSE, nulls_last = FALSE)

Expr_argsort(reverse = FALSE, nulls_last = FALSE)
```

## Arguments

- `reverse`: bool default FALSE, reverses sort
- `nulls_last`: bool, default FALSE, place Nulls last

## Returns

Expr

Get the index values that would sort this column. If 'reverse=True` the smallest elements will be given.

argsort is a alias for arg_sort

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>6</span>, <span class='fl'>1</span>, <span class='fl'>0</span>, <span class='cn'>NA</span>, <span class='cn'>Inf</span>, <span class='cn'>NaN</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>arg_sort</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (6, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ u32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
 </code></pre>