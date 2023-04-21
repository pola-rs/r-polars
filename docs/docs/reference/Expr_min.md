data

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

# min

## Format

An object of class `character` of length 1.

```r
Expr_min
```

## Returns

Expr

Get minimum value.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>x<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='cn'>NA</span>,<span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"x"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>min</span><span class='op'>(</span><span class='op'>)</span><span class='op'>==</span> <span class='fl'>1</span> <span class='op'>)</span> <span class='co'>#is true</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (1, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ x    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bool │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┘</span>
 </code></pre>