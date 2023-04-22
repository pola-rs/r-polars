# pl$count

*Source: [R/lazy_functions.R](https://github.com/pola-rs/r-polars/tree/main/R/lazy_functions.R)*

## Arguments

- `column`: if dtype is:
    
     * Series: count length of Series
     * str: count values of this column
     * NULL: count the number of value in this context.

## Returns

Expr or value-count in case Series

Count the number of values in this column/context.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>, <span class='fl'>8</span>, <span class='fl'>3</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  b <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>4</span>, <span class='fl'>5</span>, <span class='fl'>2</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  c <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"foo"</span>, <span class='st'>"bar"</span>, <span class='st'>"foo"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>count</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (1, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ count │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ u32   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>groupby</span><span class='op'>(</span><span class='st'>"c"</span>, maintain_order<span class='op'>=</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>agg</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>count</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ c   ┆ count │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str ┆ u32   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo ┆ 2     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bar ┆ 1     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴───────┘</span>
 </code></pre>