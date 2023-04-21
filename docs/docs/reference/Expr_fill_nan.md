# Fill Nulls Forward

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

## Format

a method

```r
Expr_fill_nan(expr = NULL)
```

## Arguments

- `expr`: Expr or into Expr, value to fill NaNs with

## Returns

Expr

Fill missing values with last seen values.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>l</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='cn'>NaN</span>,<span class='cn'>NaN</span>,<span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>l</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>fill_nan</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"fill_default"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>fill_nan</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='cn'>NA</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"fill_NA"</span><span class='op'>)</span>, <span class='co'>#same as default</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>fill_nan</span><span class='op'>(</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"fill_float2"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>fill_nan</span><span class='op'>(</span><span class='st'>"hej"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"fill_str"</span><span class='op'>)</span> <span class='co'>#implicit cast to Utf8</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_list</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $fill_default</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1]  1 NA NA  3</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $fill_NA</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1]  1 NA NA  3</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $fill_float2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 1 2 2 3</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $fill_str</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "1.0" "hej" "hej" "3.0"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>