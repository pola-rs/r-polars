# generic setter method

*Source: [R/dataframe__frame.R](https://github.com/pola-rs/r-polars/tree/main/R/dataframe__frame.R)*

```r
## S3 replacement method for class 'DataFrame'
self$name <- value
```

## Arguments

- `self`: DataFrame
- `name`: name method/property to set
- `value`: value to insert

## Returns

value

set value of properties of DataFrames

## Details

settable polars object properties may appear to be R objects, but they are not. See `[[method_name]]` example

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#For internal use</span></span></span>
<span class='r-in'><span><span class='co'>#is only activated for following methods of DataFrame</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/ls.html'>ls</a></span><span class='op'>(</span><span class='fu'>polars</span><span class='fu'>:::</span><span class='va'>DataFrame.property_setters</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "columns"</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#specific use case for one object property 'columns' (names)</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#get values</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='va'>columns</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width"  "Species"     </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#set + get values</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='va'>columns</span> <span class='op'>=</span> <span class='va'>letters</span><span class='op'>[</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>]</span> <span class='co'>#&lt;- is fine too</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='va'>columns</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "a" "b" "c" "d" "e"</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># Rstudio is not using the standard R code completion tool</span></span></span>
<span class='r-in'><span><span class='co'># and it will backtick any special characters. It is possible</span></span></span>
<span class='r-in'><span><span class='co'># to completely customize the R / Rstudio code completion except</span></span></span>
<span class='r-in'><span><span class='co'># it will trigger Rstudio to backtick any completion! Also R does</span></span></span>
<span class='r-in'><span><span class='co'># not support package isolated customization.</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#Concrete example if tabbing on 'df$' the raw R suggestion is df$columns&lt;-</span></span></span>
<span class='r-in'><span><span class='co'>#however Rstudio backticks it into df$`columns&lt;-`</span></span></span>
<span class='r-in'><span><span class='co'>#to make life simple, this is valid polars syntax also, and can be used in fast scripting</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='va'>`columns&lt;-`</span> <span class='op'>=</span> <span class='va'>letters</span><span class='op'>[</span><span class='fl'>5</span><span class='op'>:</span><span class='fl'>1</span><span class='op'>]</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#for stable code prefer e.g.  df$columns = letters[5:1]</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#to see inside code of a property use the [[]] syntax instead</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>[[</span><span class='st'>"columns"</span><span class='op'>]</span><span class='op'>]</span> <span class='co'># to see property code, .pr is the internal polars api into rust polars</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> function() {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .pr$DataFrame$columns(self)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;environment: 0x5644b5eb38d0&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> attr(,"class")</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "setter"   "property" "function"</span>
<span class='r-in'><span><span class='fu'>polars</span><span class='fu'>:::</span><span class='va'>DataFrame.property_setters</span><span class='op'>$</span><span class='va'>columns</span> <span class='co'>#and even more obscure to see setter code</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> function(self, names) unwrap(.pr$DataFrame$set_column_names_mut(self,names))</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;environment: namespace:polars&gt;</span>
 </code></pre>