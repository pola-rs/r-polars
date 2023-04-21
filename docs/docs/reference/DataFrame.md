# Create new DataFrame

## Arguments

- `...`:  * one data.frame or something that inherits data.frame or DataFrame
     * one list of mixed vectors and Series of equal length
     * mixed vectors and/or Series of equal length
    
    Columns will be named as of named arguments or alternatively by names of Series or given a placeholder name.
- `make_names_unique`: default TRUE, any duplicated names will be prefixed a running number
- `parallel`: bool default FALSE, experimental multithreaded interpretation of R vectors into a polars DataFrame. This is experimental as multiple threads read from R mem simultaneously. So far no issues parallel read from R has been found.

## Returns

DataFrame

Create new DataFrame

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='fl'>2</span>,<span class='fl'>3</span>,<span class='fl'>4</span>,<span class='fl'>5</span><span class='op'>)</span><span class='op'>)</span>, <span class='co'>#NB if first column should be a list, wrap it in a Series</span></span></span>
<span class='r-in'><span>  b <span class='op'>=</span> <span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span>,</span></span>
<span class='r-in'><span>  c <span class='op'>=</span> <span class='va'>letters</span><span class='op'>[</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>]</span>,</span></span>
<span class='r-in'><span>  d <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>1</span>,<span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,<span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>,<span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span>,<span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span> <span class='co'>#directly from vectors</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────┬─────┬─────┬───────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a                   ┆ b   ┆ c   ┆ d             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                 ┆ --- ┆ --- ┆ ---           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list[f64]           ┆ i32 ┆ str ┆ list[i32]     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════╪═════╪═════╪═══════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [1.0, 2.0, ... 5.0] ┆ 1   ┆ a   ┆ [1]           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [1.0, 2.0, ... 5.0] ┆ 2   ┆ b   ┆ [1, 2]        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [1.0, 2.0, ... 5.0] ┆ 3   ┆ c   ┆ [1, 2, 3]     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [1.0, 2.0, ... 5.0] ┆ 4   ┆ d   ┆ [1, 2, ... 4] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ [1.0, 2.0, ... 5.0] ┆ 5   ┆ e   ┆ [1, 2, ... 5] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────┴─────┴─────┴───────────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#from a list of vectors or data.frame</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  a<span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>1</span>,<span class='fl'>2</span>,<span class='fl'>3</span>,<span class='fl'>4</span>,<span class='fl'>5</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  b<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span>,</span></span>
<span class='r-in'><span>  c <span class='op'>=</span> <span class='va'>letters</span><span class='op'>[</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>]</span>,</span></span>
<span class='r-in'><span>  d <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fl'>1L</span>,<span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,<span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>,<span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span>,<span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 4)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┬─────┬───────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   ┆ b   ┆ c   ┆ d             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- ┆ --- ┆ ---           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 ┆ i32 ┆ str ┆ list[i32]     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╪═════╪═══════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0 ┆ 1   ┆ a   ┆ [1]           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2.0 ┆ 2   ┆ b   ┆ [1, 2]        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.0 ┆ 3   ┆ c   ┆ [1, 2, 3]     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.0 ┆ 4   ┆ d   ┆ [1, 2, ... 4] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.0 ┆ 5   ┆ e   ┆ [1, 2, ... 5] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┴─────┴───────────────┘</span>
 </code></pre>