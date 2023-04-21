# Inner workings of the Series-class

*Source: [R/series__series.R](https://github.com/pola-rs/r-polars/tree/main/R/series__series.R)*

The `Series`-class is simply two environments of respectively the public and private methods/function calls to the polars rust side. The instanciated `Series`-object is an `externalptr` to a lowlevel rust polars Series object. The pointer address is the only statefullness of the Series object on the R side. Any other state resides on the rust side. The S3 method `.DollarNames.Series` exposes all public `$foobar()`-methods which are callable onto the object. Most methods return another `Series`-class instance or similar which allows for method chaining. This class system in lack of a better name could be called "environment classes" and is the same class system extendr provides, except here there is both a public and private set of methods. For implementation reasons, the private methods are external and must be called from polars:::.pr.$Series$methodname(), also all private methods must take any self as an argument, thus they are pure functions. Having the private methods as pure functions solved/simplified self-referential complications.

## Details

Check out the source code in R/Series_frame.R how public methods are derived from private methods. Check out extendr-wrappers.R to see the extendr-auto-generated methods. These are moved to .pr and converted into pure external functions in after-wrappers.R. In zzz.R (named zzz to be last file sourced) the extendr-methods are removed and replaced by any function prefixed `Series_`.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#see all exported methods</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/ls.html'>ls</a></span><span class='op'>(</span><span class='fu'>polars</span><span class='fu'>:::</span><span class='va'><a href='https://rdrr.io/pkg/polars/man/Series.html'>Series</a></span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [1] "abs"           "add"           "alias"         "all"           "any"          </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [6] "append"        "apply"         "arg_max"       "arg_min"       "arr"          </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [11] "ceil"          "chunk_lengths" "clone"         "compare"       "cumsum"       </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [16] "div"           "dtype"         "expr"          "flags"         "floor"        </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [21] "is_numeric"    "is_sorted"     "len"           "max"           "min"          </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [26] "mul"           "name"          "print"         "rem"           "rename"       </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [31] "rep"           "series_equal"  "set_sorted"    "shape"         "sort"         </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [36] "std"           "sub"           "sum"           "to_frame"      "to_lit"       </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [41] "to_r"          "to_r_list"     "to_r_vector"   "to_vector"     "value_counts" </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [46] "var"          </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#see all private methods (not intended for regular use)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/ls.html'>ls</a></span><span class='op'>(</span><span class='fu'>polars</span><span class='fu'>:::</span><span class='va'><a href='https://rdrr.io/pkg/polars/man/dot-pr.html'>.pr</a></span><span class='op'>$</span><span class='va'>Series</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [1] "abs"                    "add"                    "alias"                 </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [4] "all"                    "any"                    "append_mut"            </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [7] "apply"                  "arg_max"                "arg_min"               </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [10] "ceil"                   "chunk_lengths"          "clone"                 </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [13] "compare"                "cumsum"                 "div"                   </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [16] "dtype"                  "floor"                  "from_arrow"            </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [19] "get_fmt"                "is_sorted"              "is_sorted_flag"        </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [22] "is_sorted_reverse_flag" "len"                    "max"                   </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [25] "min"                    "mul"                    "name"                  </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [28] "new"                    "panic"                  "print"                 </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [31] "rem"                    "rename_mut"             "rep"                   </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [34] "series_equal"           "set_sorted_mut"         "shape"                 </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [37] "sleep"                  "sort_mut"               "sub"                   </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [40] "sum"                    "to_frame"               "to_r"                  </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [43] "value_counts"          </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#make an object</span></span></span>
<span class='r-in'><span><span class='va'>s</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#use a public method/property</span></span></span>
<span class='r-in'><span><span class='va'>s</span><span class='op'>$</span><span class='va'>shape</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 3 1</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#use a private method (mutable append not allowed in public api)</span></span></span>
<span class='r-in'><span><span class='va'>s_copy</span> <span class='op'>=</span> <span class='va'>s</span></span></span>
<span class='r-in'><span><span class='va'>.pr</span><span class='op'>$</span><span class='va'>Series</span><span class='op'>$</span><span class='fu'>append_mut</span><span class='op'>(</span><span class='va'>s</span>, <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>5</span><span class='op'>:</span><span class='fl'>1</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $ok</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $err</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> attr(,"class")</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "extendr_result"</span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/identical.html'>identical</a></span><span class='op'>(</span><span class='va'>s_copy</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span>, <span class='va'>s</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span> <span class='co'># s_copy was modified when s was modified</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
 </code></pre>