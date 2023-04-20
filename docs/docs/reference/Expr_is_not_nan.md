data

# Are elements not NaN's

## Format

a method

```r
Expr_is_not_nan
```

## Returns

Expr

Returns a boolean Series indicating which values are not NaN.

## Details

Floating point NaN's are a different flag from Null(polars) which is the same as NA_real_(R).

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>alice<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>0</span>,<span class='cn'>NaN</span>,<span class='cn'>NA</span>,<span class='cn'>Inf</span>,<span class='op'>-</span><span class='cn'>Inf</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"alice"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_not_nan</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ alice │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bool  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┘</span>
 </code></pre>