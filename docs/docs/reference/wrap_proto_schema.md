# wrap proto schema

## Format

function

```r
wrap_proto_schema(x)
```

## Arguments

- `x`: either schema, or incomplete schema where dataType can be NULL or schema is just char vec, implicitly the same as if all DataType are NULL, mean undefinesd.

## Returns

bool

wrap proto schema

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='fu'>polars</span><span class='fu'>:::</span><span class='fu'><a href='https://rdrr.io/pkg/polars/man/wrap_proto_schema.html'>wrap_proto_schema</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"alice"</span>,<span class='st'>"bob"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $alice</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $bob</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span><span class='fu'>polars</span><span class='fu'>:::</span><span class='fu'><a href='https://rdrr.io/pkg/polars/man/wrap_proto_schema.html'>wrap_proto_schema</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='st'>"alice"</span><span class='op'>=</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Int64</span>,<span class='st'>"bob"</span><span class='op'>=</span><span class='cn'>NULL</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $alice</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Int64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $bob</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>