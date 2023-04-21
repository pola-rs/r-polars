# Inner workings of the DataFrame-class

The `DataFrame`-class is simply two environments of respectively the public and private methods/function calls to the polars rust side. The instanciated `DataFrame`-object is an `externalptr` to a lowlevel rust polars DataFrame object. The pointer address is the only statefullness of the DataFrame object on the R side. Any other state resides on the rust side. The S3 method `.DollarNames.DataFrame`

exposes all public `$foobar()`-methods which are callable onto the object. Most methods return another `DataFrame`-class instance or similar which allows for method chaining. This class system in lack of a better name could be called "environment classes" and is the same class system extendr provides, except here there is both a public and private set of methods. For implementation reasons, the private methods are external and must be called from polars:::.pr.$DataFrame$methodname(), also all private methods must take any self as an argument, thus they are pure functions. Having the private methods as pure functions solved/simplified self-referential complications.

## Details

Check out the source code in R/dataframe_frame.R how public methods are derived from private methods. Check out extendr-wrappers.R to see the extendr-auto-generated methods. These are moved to .pr and converted into pure external functions in after-wrappers.R. In zzz.R (named zzz to be last file sourced) the extendr-methods are removed and replaced by any function prefixed `DataFrame_`.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#see all exported methods</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/ls.html'>ls</a></span><span class='op'>(</span><span class='fu'>polars</span><span class='fu'>:::</span><span class='va'><a href='https://rdrr.io/pkg/polars/man/DataFrame.html'>DataFrame</a></span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [1] "as_data_frame"  "clone"          "columns"        "dtypes"         "estimated_size" "filter"         "first"          "get_column"    </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [9] "get_columns"    "groupby"        "height"         "join"           "last"           "lazy"           "limit"          "max"           </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [17] "mean"           "median"         "min"            "null_count"     "print"          "reverse"        "schema"         "select"        </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [25] "shape"          "slice"          "std"            "sum"            "tail"           "to_list"        "to_series"      "to_struct"     </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [33] "unnest"         "var"            "width"          "with_column"    "with_columns"  </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#see all private methods (not intended for regular use)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/ls.html'>ls</a></span><span class='op'>(</span><span class='fu'>polars</span><span class='fu'>:::</span><span class='va'><a href='https://rdrr.io/pkg/polars/man/dot-pr.html'>.pr</a></span><span class='op'>$</span><span class='va'>DataFrame</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [1] "by_agg"                    "clone_see_me_macro"        "columns"                   "dtypes"                    "estimated_size"           </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [6] "export_stream"             "from_arrow_record_batches" "get_column"                "get_columns"               "lazy"                     </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [11] "new"                       "new_par_from_list"         "new_with_capacity"         "null_count"                "print"                    </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [16] "schema"                    "select"                    "select_at_idx"             "set_column_from_robj"      "set_column_from_series"   </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [21] "set_column_names_mut"      "shape"                     "to_list"                   "to_list_tag_structs"       "to_list_unwind"           </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [26] "to_struct"                 "unnest"                   </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#make an object</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#use a public method/property</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='va'>shape</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 150   5</span>
<span class='r-in'><span><span class='va'>df2</span> <span class='op'>=</span> <span class='va'>df</span></span></span>
<span class='r-in'><span><span class='co'>#use a private method, which has mutability</span></span></span>
<span class='r-in'><span><span class='va'>result</span> <span class='op'>=</span> <span class='fu'>polars</span><span class='fu'>:::</span><span class='va'><a href='https://rdrr.io/pkg/polars/man/dot-pr.html'>.pr</a></span><span class='op'>$</span><span class='va'>DataFrame</span><span class='op'>$</span><span class='fu'>set_column_from_robj</span><span class='op'>(</span><span class='va'>df</span>,<span class='fl'>150</span><span class='op'>:</span><span class='fl'>1</span>,<span class='st'>"some_ints"</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#column exists in both dataframes-objects now, as they are just pointers to the same object</span></span></span>
<span class='r-in'><span><span class='co'># there are no public methods with mutability</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='va'>columns</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width"  "Species"      "some_ints"   </span>
<span class='r-in'><span><span class='va'>df2</span><span class='op'>$</span><span class='va'>columns</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width"  "Species"      "some_ints"   </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># set_column_from_robj-method is fallible and returned a result which could be ok or an err.</span></span></span>
<span class='r-in'><span><span class='co'># No public method or function will ever return a result.</span></span></span>
<span class='r-in'><span><span class='co'># The `result` is very close to the same as output from functions decorated with purrr::safely.</span></span></span>
<span class='r-in'><span><span class='co'># To use results on R side, these must be unwrapped first such that</span></span></span>
<span class='r-in'><span><span class='co'># potentially errors can be thrown. unwrap(result) is a way to</span></span></span>
<span class='r-in'><span><span class='co'># bridge rust not throwing errors with R. Extendr default behaviour is to use panic!(s) which</span></span></span>
<span class='r-in'><span><span class='co'># would case some unneccesary confusing and  some very verbose error messages on the inner</span></span></span>
<span class='r-in'><span><span class='co'># workings of rust. unwrap(result) #in this case no error, just a NULL because this mutable</span></span></span>
<span class='r-in'><span><span class='co'># method does not return any ok-value.</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#try unwrapping an error from polars due to unmatching column lengths</span></span></span>
<span class='r-in'><span><span class='va'>err_result</span> <span class='op'>=</span> <span class='fu'>polars</span><span class='fu'>:::</span><span class='va'><a href='https://rdrr.io/pkg/polars/man/dot-pr.html'>.pr</a></span><span class='op'>$</span><span class='va'>DataFrame</span><span class='op'>$</span><span class='fu'>set_column_from_robj</span><span class='op'>(</span><span class='va'>df</span>,<span class='fl'>1</span><span class='op'>:</span><span class='fl'>10000</span>,<span class='st'>"wrong_length"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='kw'><a href='https://rdrr.io/r/base/conditions.html'>tryCatch</a></span><span class='op'>(</span><span class='fu'>unwrap</span><span class='op'>(</span><span class='va'>err_result</span>,call<span class='op'>=</span><span class='cn'>NULL</span><span class='op'>)</span>,error<span class='op'>=</span>\<span class='op'>(</span><span class='va'>e</span><span class='op'>)</span> <span class='fu'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/character.html'>as.character</a></span><span class='op'>(</span><span class='va'>e</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Error: in set_column_from_robj: ShapeMisMatch(Owned("Could not add column. The Series length 10000 differs from the DataFrame height: 150")) </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  when calling :</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  NULL</span>
 </code></pre>