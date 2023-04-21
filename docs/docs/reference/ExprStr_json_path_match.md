# json_path_match

*Source: [R/expr__string.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__string.R)*

## Arguments

- `json_path`: A valid JSON path query string.

## Returns

Utf8 array. Contain null if original value is null or the json_path return nothing.

Extract the first match of json string with provided JSONPath expression.

## Details

Throw errors if encounter invalid json strings. All return value will be casted to Utf8 regardless of the original value. Documentation on JSONPath standard can be found `here <https://goessner.net/articles/JsonPath/>`_.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  json_val <span class='op'>=</span>  <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>'{"a":"1"}'</span>, <span class='cn'>NA</span>, <span class='st'>'{"a":2}'</span>, <span class='st'>'{"a":2.1}'</span>, <span class='st'>'{"a":true}'</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"json_val"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>json_path_match</span><span class='op'>(</span><span class='st'>"$.a"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ json_val │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2.1      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────┘</span>
 </code></pre>