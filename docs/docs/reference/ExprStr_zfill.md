# zfill

## Arguments

- `alignment`: Fill the value up to this length

## Returns

Expr

Fills the string with zeroes.

## Details

Return a copy of the string left filled with ASCII '0' digits to make a string of length width.

A leading sign prefix ('+'/'-') is handled by inserting the padding after the sign character rather than before. The original string is returned if width is less than or equal to `len(s)`.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>some_floats_expr</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>0</span>,<span class='fl'>10</span>,<span class='op'>-</span><span class='fl'>5</span>,<span class='fl'>5</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#cast to Utf8 and ljust alignment = 5, and view as R char vector</span></span></span>
<span class='r-in'><span><span class='va'>some_floats_expr</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>zfill</span><span class='op'>(</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "000.0" "010.0" "-05.0" "005.0"</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#cast to int and the to utf8 and then ljust alignment = 5, and view as R char vector</span></span></span>
<span class='r-in'><span><span class='va'>some_floats_expr</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Int64</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>zfill</span><span class='op'>(</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "00000" "00010" "-0005" "00005"</span>
 </code></pre>