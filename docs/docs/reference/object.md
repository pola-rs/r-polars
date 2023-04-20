data

# Any polars class object is made of this

## Format

An object of class `character` of length 1.

```r
object
```

One SEXP of Rtype: "externalptr" + a class attribute

## Details

 * `object$method()` calls are facilitated by a `$.ClassName`- s3method see 'R/after-wrappers.R'
 * Code completion is facilitted by `.DollarNames.ClassName`-s3method see e.g. 'R/dataframe__frame.R'
 * Implementation of property-methods as DataFrame_columns() and syntax checking is an extension to `$.ClassName`
   
   See function macro_add_syntax_check_to_class().

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#all a polars object is made of:</span></span></span>
<span class='r-in'><span><span class='va'>some_polars_object</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='op'>(</span><span class='va'>some_polars_object</span><span class='op'>)</span> <span class='co'>#External Pointer tagged with a class attribute.</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Class 'DataFrame' &lt;externalptr&gt; </span>
 </code></pre>