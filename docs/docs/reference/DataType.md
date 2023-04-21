# DataTypes polars types

`DataType` any polars type (ported so far)

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/ls.html'>ls</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [1] "Binary"      "Boolean"     "Categorical" "Date"        "Datetime"   </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [6] "Float32"     "Float64"     "Int16"       "Int32"       "Int64"      </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [11] "Int8"        "List"        "Null"        "Struct"      "Time"       </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [16] "UInt16"      "UInt32"      "UInt64"      "UInt8"       "Unknown"    </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [21] "Utf8"       </span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>Float64</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Float64</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>Utf8</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Utf8</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>List</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>List</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>UInt64</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: List(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     List(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         UInt64,</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     ),</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> )</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Struct</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Field</span><span class='op'>(</span><span class='st'>"CityNames"</span>, <span class='va'>pl</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Struct(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         Field {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             name: "CityNames",</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             dtype: Utf8,</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         },</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     ],</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> )</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># Some DataType use case, this user function fails because....</span></span></span>
<span class='r-in'><span><span class='co'>## Not run:</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>apply</span><span class='op'>(</span>\<span class='op'>(</span><span class='va'>x</span><span class='op'>)</span> <span class='va'>letters</span><span class='op'>[</span><span class='va'>x</span><span class='op'>]</span><span class='op'>)</span></span></span>
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error:</span> a lambda returned Strings and not the expected Integers .  Try strict=FALSE, or change expected output type or rewrite lambda </span>
<span class='r-err co'><span class='r-pr'>#&gt;</span>  when calling :</span>
<span class='r-err co'><span class='r-pr'>#&gt;</span>  source("~/Bureau/Git/not_my_packages/r-polars/make-docs.R", echo = TRUE)</span>
<span class='r-in'><span><span class='co'>## End(Not run)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#The function changes type from Integer(Int32)[Integers] to char(Utf8)[Strings]</span></span></span>
<span class='r-in'><span><span class='co'>#specifying the output DataType: Utf8 solves the problem</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>apply</span><span class='op'>(</span>\<span class='op'>(</span><span class='va'>x</span><span class='op'>)</span> <span class='va'>letters</span><span class='op'>[</span><span class='va'>x</span><span class='op'>]</span>,datatype <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (4,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '_apply' [str]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"a"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"b"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"c"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	"d"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>