# Generate autocompletion suggestions for object

```r
get_method_usages(env, pattern = "")
```

## Arguments

- `env`: environment to extract usages from
- `pattern`: string passed to ls(pattern) to subset methods by pattern

## Returns

method usages

Generate autocompletion suggestions for object

## Details

used internally for auto completion in .DollarNames methods

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='fu'>polars</span><span class='fu'>:::</span><span class='fu'><a href='https://rdrr.io/pkg/polars/man/get_method_usages.html'>get_method_usages</a></span><span class='op'>(</span><span class='fu'>polars</span><span class='fu'>:::</span><span class='va'><a href='https://rdrr.io/pkg/polars/man/DataFrame.html'>DataFrame</a></span>, pattern<span class='op'>=</span><span class='st'>"col"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "columns"        "columns&lt;-"      "get_column()"   "get_columns()"  "with_column()"  "with_columns()"</span>
 </code></pre>