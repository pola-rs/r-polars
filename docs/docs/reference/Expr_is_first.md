data

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

# Get a mask of the first unique value.

## Format

a method

```r
Expr_is_first
```

## Returns

Expr (boolean)

Get a mask of the first unique value.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>v</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='fl'>1</span>,<span class='fl'>2</span>,<span class='fl'>2</span>,<span class='fl'>3</span>,<span class='cn'>NA</span>,<span class='cn'>NaN</span>,<span class='cn'>Inf</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/all.equal.html'>all.equal</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>    <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='va'>v</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_unique</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"is_unique"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='va'>v</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_first</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"is_first"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='va'>v</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_duplicated</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"is_duplicated"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='va'>v</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_first</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_not</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"R_duplicated"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='op'>)</span><span class='op'>$</span><span class='fu'>to_list</span><span class='op'>(</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>    is_unique <span class='op'>=</span> <span class='op'>!</span><span class='va'>v</span> <span class='op'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='va'>v</span><span class='op'>[</span><span class='fu'><a href='https://rdrr.io/r/base/duplicated.html'>duplicated</a></span><span class='op'>(</span><span class='va'>v</span><span class='op'>)</span><span class='op'>]</span>,</span></span>
<span class='r-in'><span>    is_first  <span class='op'>=</span> <span class='op'>!</span><span class='fu'><a href='https://rdrr.io/r/base/duplicated.html'>duplicated</a></span><span class='op'>(</span><span class='va'>v</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    is_duplicated <span class='op'>=</span> <span class='va'>v</span> <span class='op'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='va'>v</span><span class='op'>[</span><span class='fu'><a href='https://rdrr.io/r/base/duplicated.html'>duplicated</a></span><span class='op'>(</span><span class='va'>v</span><span class='op'>)</span><span class='op'>]</span>,</span></span>
<span class='r-in'><span>    R_duplicated <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/duplicated.html'>duplicated</a></span><span class='op'>(</span><span class='va'>v</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
 </code></pre>