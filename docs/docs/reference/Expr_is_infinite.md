data

# Are elements infinite

## Format

a method

```r
Expr_is_infinite
```

## Returns

Expr

Returns a boolean output indicating which values are infinite.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>alice<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>0</span>,<span class='cn'>NaN</span>,<span class='cn'>NA</span>,<span class='cn'>Inf</span>,<span class='op'>-</span><span class='cn'>Inf</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"alice"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_infinite</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ alice │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bool  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┘</span>
 </code></pre>