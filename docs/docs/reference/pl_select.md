# Select from an empty DataFrame

## Format

method

## Returns

DataFrame

Select from an empty DataFrame

## Details

param ... expressions passed to select `pl$select` is a shorthand for `pl$DataFrame(list())$select`

NB param of this function

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"ints"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='va'>letters</span><span class='op'>[</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>]</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"letters"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ints ┆ letters │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32  ┆ str     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1    ┆ a       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2    ┆ b       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3    ┆ c       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4    ┆ d       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴─────────┘</span>
 </code></pre>