# Fill Nulls Forward

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

## Format

a method

```r
Expr_forward_fill(limit = NULL)
```

## Arguments

- `limit`: Expr or `Into<Expr>` The number of consecutive null values to forward fill.

## Returns

Expr

Fill missing values with last seen values.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>l</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1L</span>,<span class='fu'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='op'>(</span><span class='cn'>NA_integer_</span>,<span class='fl'>3L</span><span class='op'>)</span>,<span class='fl'>10</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>l</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>forward_fill</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"ff_null"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>forward_fill</span><span class='op'>(</span>limit <span class='op'>=</span> <span class='fl'>0</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"ff_l0"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>forward_fill</span><span class='op'>(</span>limit <span class='op'>=</span> <span class='fl'>1</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"ff_l1"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_list</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $ff_null</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1]  1  1  1  1 10</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $ff_l0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1]  1 NA NA NA 10</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $ff_l1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1]  1  1 NA NA 10</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>