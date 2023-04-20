# rjust

## Arguments

- `width`: Justify left to this length.
- `fillchar`: Fill with this ASCII character.

## Returns

Expr of Utf8

Return the string left justified in a string of length `width`.

## Details

Padding is done using the specified `fillchar`. The original string is returned if `width` is less than or equal to `len(s)`.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"cow"</span>, <span class='st'>"monkey"</span>, <span class='cn'>NA</span>, <span class='st'>"hippopotamus"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>rjust</span><span class='op'>(</span><span class='fl'>8</span>, <span class='st'>"*"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ *****cow     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ **monkey     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ hippopotamus │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┘</span>
 </code></pre>