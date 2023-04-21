data

# Count values (len is a alias)

## Format

An object of class `character` of length 1.

An object of class `character` of length 1.

```r
Expr_count

Expr_len
```

## Returns

Expr

Expr

Count the number of values in this expression. Similar to R length()

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  all<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>,<span class='cn'>TRUE</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  any<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>,<span class='cn'>FALSE</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  none<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>FALSE</span>,<span class='cn'>FALSE</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>count</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ all ┆ any ┆ none │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ u32 ┆ u32 ┆ u32  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ 2   ┆ 2    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┴──────┘</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  all<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>,<span class='cn'>TRUE</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  any<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>,<span class='cn'>FALSE</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  none<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>FALSE</span>,<span class='cn'>FALSE</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>len</span><span class='op'>(</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"all"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>first</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>len</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"all_first"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┬──────┬───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ all ┆ any ┆ none ┆ all_first │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- ┆ ---  ┆ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ u32 ┆ u32 ┆ u32  ┆ u32       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╪══════╪═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ 2   ┆ 2    ┆ 1         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┴──────┴───────────┘</span>
 </code></pre>