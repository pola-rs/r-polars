# To uppercase

## Returns

Expr of Utf8 uppercase chars

Transform to uppercase variant.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"A"</span>,<span class='st'>"b"</span>, <span class='st'>"c"</span>, <span class='st'>"1"</span>, <span class='cn'>NA</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>to_uppercase</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (5,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [str]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"A"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"B"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"C"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"1"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	null</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>