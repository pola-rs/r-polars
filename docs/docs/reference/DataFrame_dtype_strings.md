data

# DataFrame dtype strings

## Format

An object of class `character` of length 1.

```r
DataFrame_dtype_strings
```

## Returns

string vector

Get column types as strings.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>dtype_strings</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "f64" "f64" "f64" "f64" "cat"</span>
 </code></pre>