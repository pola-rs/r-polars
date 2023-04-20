# Expr_sort

## Format

a method

```r
Expr_sort(reverse = FALSE, nulls_last = FALSE)
```

## Arguments

- `reverse`: bool default FALSE, reverses sort
- `nulls_last`: bool, default FALSE, place Nulls last

## Returns

Expr

Sort this column. In projection/ selection context the whole column is sorted. If used in a groupby context, the groups are sorted.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>6</span>, <span class='fl'>1</span>, <span class='fl'>0</span>, <span class='cn'>NA</span>, <span class='cn'>Inf</span>, <span class='cn'>NaN</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (6, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ inf  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ NaN  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┘</span>
 </code></pre>