# Create List DataType

## Format

function

## Arguments

- `datatype`: an inner DataType

## Returns

a list DataType with an inner DataType

Create List DataType

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>List</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>List</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Boolean</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: List(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     List(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         Boolean,</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     ),</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> )</span>
 </code></pre>