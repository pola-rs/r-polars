# is_numeric

## Format

method

```r
Series_is_numeric()
```

## Returns

bool

return bool whether series is numeric

## Details

true of series dtype is member of pl$numeric_dtypes

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_numeric</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a"</span>,<span class='st'>"b"</span>,<span class='st'>"c"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_numeric</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
<span class='r-in'><span> <span class='va'>pl</span><span class='op'>$</span><span class='va'>numeric_dtypes</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Int8</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Int8</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Int16</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Int16</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Int32</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Int32</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Int64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Int64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Float32</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Float32</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Float64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Float64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>