# To lowercase

## Returns

Expr of Utf8 lowercase chars

Transform to lowercase variant.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"A"</span>,<span class='st'>"b"</span>, <span class='st'>"c"</span>, <span class='st'>"1"</span>, <span class='cn'>NA</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>to_lowercase</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (5,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [str]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"a"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"b"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"c"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"1"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	null</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>