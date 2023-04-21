# json_extract

## Arguments

- `dtype`: The dtype to cast the extracted value to. If None, the dtype will be inferred from the JSON value.

## Returns

Expr returning a boolean

Parse string values as JSON.

## Details

Throw errors if encounter invalid json strings.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  json_val <span class='op'>=</span>  <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>'{"a":1, "b": true}'</span>, <span class='cn'>NA</span>, <span class='st'>'{"a":2, "b": false}'</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>dtype</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Struct</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Field</span><span class='op'>(</span><span class='st'>"a"</span>, <span class='va'>pl</span><span class='op'>$</span><span class='va'>Int64</span><span class='op'>)</span>, <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Field</span><span class='op'>(</span><span class='st'>"b"</span>, <span class='va'>pl</span><span class='op'>$</span><span class='va'>Boolean</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"json_val"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>json_extract</span><span class='op'>(</span><span class='va'>dtype</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ json_val    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ struct[2]   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {1,true}    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {null,null} │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {2,false}   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────┘</span>
 </code></pre>