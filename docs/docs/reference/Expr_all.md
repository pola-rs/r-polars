data

# All, is true

## Format

An object of class `character` of length 1.

```r
Expr_all
```

## Returns

Boolean literal

Check if all boolean values in a Boolean column are `TRUE`. This method is an expression - not to be confused with `pl$all` which is a function to select all columns.

## Details

last `all()` in example is this Expr method, the first `pl$all()` refers to "all-columns" and is an expression constructor

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  all<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>,<span class='cn'>TRUE</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  any<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>,<span class='cn'>FALSE</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  none<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>FALSE</span>,<span class='cn'>FALSE</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬───────┬───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ all  ┆ any   ┆ none  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---   ┆ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bool ┆ bool  ┆ bool  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═══════╪═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true ┆ false ┆ false │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴───────┴───────┘</span>
 </code></pre>