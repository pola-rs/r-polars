# encode

## Arguments

- `encoding`: string choice either 'hex' or 'base64'

## Returns

Utf8 array with values encoded using provided encoding

Encode a value using the provided encoding.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span> strings <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"foo"</span>, <span class='st'>"bar"</span>, <span class='cn'>NA</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"strings"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>encode</span><span class='op'>(</span><span class='st'>"hex"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ strings │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 666f6f  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 626172  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"strings"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>encode</span><span class='op'>(</span><span class='st'>"base64"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"base64"</span><span class='op'>)</span>, <span class='co'>#notice DataType is not encoded</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"strings"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>encode</span><span class='op'>(</span><span class='st'>"hex"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"hex"</span><span class='op'>)</span>       <span class='co'>#... and must restored with cast</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"base64"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>decode</span><span class='op'>(</span><span class='st'>"base64"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"base64_decoded"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"hex"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>decode</span><span class='op'>(</span><span class='st'>"hex"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"hex_decoded"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 5)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────┬────────┬────────┬────────────────┬─────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ strings ┆ base64 ┆ hex    ┆ base64_decoded ┆ hex_decoded │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---     ┆ ---    ┆ ---    ┆ ---            ┆ ---         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str     ┆ str    ┆ str    ┆ str            ┆ str         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════╪════════╪════════╪════════════════╪═════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo     ┆ Zm9v   ┆ 666f6f ┆ foo            ┆ foo         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bar     ┆ YmFy   ┆ 626172 ┆ bar            ┆ bar         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null    ┆ null   ┆ null   ┆ null           ┆ null        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────┴────────┴────────┴────────────────┴─────────────┘</span>
 </code></pre>