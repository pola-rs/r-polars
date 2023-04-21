# check if x is a valid RPolarsDataType

## Arguments

- `lhs`: an RPolarsDataType
- `rhs`: an RPolarsDataType

## Returns

bool TRUE if outer datatype is the same.

check if x is a valid RPolarsDataType

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'># TRUE</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>same_outer_dt</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Datetime</span><span class='op'>(</span><span class='st'>"us"</span><span class='op'>)</span>,<span class='va'>pl</span><span class='op'>$</span><span class='fu'>Datetime</span><span class='op'>(</span><span class='st'>"ms"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>same_outer_dt</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>List</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Int64</span><span class='op'>)</span>,<span class='va'>pl</span><span class='op'>$</span><span class='fu'>List</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Float32</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#FALSE</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>same_outer_dt</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Int64</span>,<span class='va'>pl</span><span class='op'>$</span><span class='va'>Float64</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
 </code></pre>