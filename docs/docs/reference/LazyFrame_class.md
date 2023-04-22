# Inner workings of the LazyFrame-class

*Source: [R/lazyframe__lazy.R](https://github.com/pola-rs/r-polars/tree/main/R/lazyframe__lazy.R)*

The `LazyFrame`-class is simply two environments of respectively the public and private methods/function calls to the polars rust side. The instanciated `LazyFrame`-object is an `externalptr` to a lowlevel rust polars LazyFrame object. The pointer address is the only statefullness of the LazyFrame object on the R side. Any other state resides on the rust side. The S3 method `.DollarNames.LazyFrame` exposes all public `$foobar()`-methods which are callable onto the object. Most methods return another `LazyFrame`-class instance or similar which allows for method chaining. This class system in lack of a better name could be called "environment classes" and is the same class system extendr provides, except here there is both a public and private set of methods. For implementation reasons, the private methods are external and must be called from polars:::.pr.$LazyFrame$methodname(), also all private methods must take any self as an argument, thus they are pure functions. Having the private methods as pure functions solved/simplified self-referential complications.

`DataFrame` and `LazyFrame` can both be said to be a `Frame`. To convert use `DataFrame_object$lazy() -> LazyFrame_object` and `LazyFrame_object$collect() -> DataFrame_object`. This is quite similar to the lazy-collect syntax of the dplyrpackage to interact with database connections such as SQL variants. Most SQL databases would be able to perform the same otimizations as polars such Predicate Pushdown and Projection. However polars can intertact and optimize queries with both SQL DBs and other data sources such parquet files simultanously. (#TODO implement r-polars SQL ;)

## Details

Check out the source code in R/LazyFrame__lazy.R how public methods are derived from private methods. Check out extendr-wrappers.R to see the extendr-auto-generated methods. These are moved to .pr and converted into pure external functions in after-wrappers.R. In zzz.R (named zzz to be last file sourced) the extendr-methods are removed and replaced by any function prefixed `LazyFrame_`.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#see all exported methods</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/ls.html'>ls</a></span><span class='op'>(</span><span class='fu'>polars</span><span class='fu'>:::</span><span class='va'>LazyFrame</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [1] "collect"                 "collect_background"      "describe_optimized_plan" "describe_plan"           "drop"                   </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [6] "drop_nulls"              "fill_nan"                "fill_null"               "filter"                  "first"                  </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [11] "groupby"                 "join"                    "last"                    "limit"                   "max"                    </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [16] "mean"                    "median"                  "min"                     "print"                   "quantile"               </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [21] "reverse"                 "select"                  "shift"                   "shift_and_fill"          "slice"                  </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [26] "sort"                    "std"                     "sum"                     "tail"                    "unique"                 </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [31] "var"                     "with_column"             "with_columns"           </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#see all private methods (not intended for regular use)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/ls.html'>ls</a></span><span class='op'>(</span><span class='fu'>polars</span><span class='fu'>:::</span><span class='va'><a href='https://rdrr.io/pkg/polars/man/dot-pr.html'>.pr</a></span><span class='op'>$</span><span class='va'>LazyFrame</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [1] "collect"                 "collect_background"      "describe_optimized_plan" "describe_plan"           "drop"                   </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [6] "drop_nulls"              "fill_nan"                "fill_null"               "filter"                  "first"                  </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [11] "groupby"                 "join"                    "last"                    "limit"                   "max"                    </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [16] "mean"                    "median"                  "min"                     "print"                   "quantile"               </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [21] "reverse"                 "select"                  "shift"                   "shift_and_fill"          "slice"                  </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [26] "sort_by_exprs"           "std"                     "sum"                     "tail"                    "unique"                 </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [31] "var"                     "with_column"             "with_columns"           </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>## Practical example ##</span></span></span>
<span class='r-in'><span><span class='co'># First writing R iris dataset to disk, to illustrte a difference</span></span></span>
<span class='r-in'><span><span class='va'>temp_filepath</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/tempfile.html'>tempfile</a></span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/utils/write.table.html'>write.csv</a></span><span class='op'>(</span><span class='va'>iris</span>, <span class='va'>temp_filepath</span>,row.names <span class='op'>=</span> <span class='cn'>FALSE</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># Following example illustrates 2 ways to obtain a LazyFrame</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># The-Okay-way: convert an in-memory DataFrame to LazyFrame</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#eager in-mem R data.frame</span></span></span>
<span class='r-in'><span><span class='va'>Rdf</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/utils/read.table.html'>read.csv</a></span><span class='op'>(</span><span class='va'>temp_filepath</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#eager in-mem polars DataFrame</span></span></span>
<span class='r-in'><span><span class='va'>Pdf</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>Rdf</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#lazy frame starting from in-mem DataFrame</span></span></span>
<span class='r-in'><span><span class='va'>Ldf_okay</span> <span class='op'>=</span> <span class='va'>Pdf</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#The-Best-Way:  LazyFrame created directly from a data source is best...</span></span></span>
<span class='r-in'><span><span class='va'>Ldf_best</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lazy_csv_reader</span><span class='op'>(</span><span class='va'>temp_filepath</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># ... as if to e.g. filter the LazyFrame, that filtering also caleld predicate will be</span></span></span>
<span class='r-in'><span><span class='co'># pushed down in the executation stack to the csv_reader, and thereby only bringing into</span></span></span>
<span class='r-in'><span><span class='co'># memory the rows matching to filter.</span></span></span>
<span class='r-in'><span><span class='co'># apply filter:</span></span></span>
<span class='r-in'><span><span class='va'>filter_expr</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Species"</span><span class='op'>)</span> <span class='op'>==</span> <span class='st'>"setosa"</span> <span class='co'>#get only rows where Species is setosa</span></span></span>
<span class='r-in'><span><span class='va'>Ldf_okay</span> <span class='op'>=</span> <span class='va'>Ldf_okay</span><span class='op'>$</span><span class='fu'>filter</span><span class='op'>(</span><span class='va'>filter_expr</span><span class='op'>)</span> <span class='co'>#overwrite LazyFrame with new</span></span></span>
<span class='r-in'><span><span class='va'>Ldf_best</span> <span class='op'>=</span> <span class='va'>Ldf_best</span><span class='op'>$</span><span class='fu'>filter</span><span class='op'>(</span><span class='va'>filter_expr</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># the non optimized plans are similar, on entire in-mem csv, apply filter</span></span></span>
<span class='r-in'><span><span class='va'>Ldf_okay</span><span class='op'>$</span><span class='fu'>describe_plan</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   FILTER [(col("Species")) == (Utf8(setosa))] FROM</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"]; PROJECT */5 COLUMNS; SELECTION: "None"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span><span class='va'>Ldf_best</span><span class='op'>$</span><span class='fu'>describe_plan</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   FILTER [(col("Species")) == (Utf8(setosa))] FROM</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     CSV SCAN C:\Users\etienne\AppData\Local\Temp\RtmpkVIA0E\file3c24776e7188</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     PROJECT */5 COLUMNS</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># NOTE For Ldf_okay, the full time to load csv alrady paid when creating Rdf and Pdf</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#The optimized plan are quite different, Ldf_best will read csv and perform filter simultanously</span></span></span>
<span class='r-in'><span><span class='va'>Ldf_okay</span><span class='op'>$</span><span class='fu'>describe_optimized_plan</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"]; PROJECT */5 COLUMNS; SELECTION: "[(col(\"Species\")) == (Utf8(setosa))]"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span><span class='va'>Ldf_best</span><span class='op'>$</span><span class='fu'>describe_optimized_plan</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   CSV SCAN C:\Users\etienne\AppData\Local\Temp\RtmpkVIA0E\file3c24776e7188</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   PROJECT */5 COLUMNS</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   SELECTION: [(col("Species")) == (Utf8(setosa))]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#To acquire result in-mem use $colelct()</span></span></span>
<span class='r-in'><span><span class='va'>Pdf_okay</span> <span class='op'>=</span> <span class='va'>Ldf_okay</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>Pdf_best</span> <span class='op'>=</span> <span class='va'>Ldf_best</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#verify tables would be the same</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/all.equal.html'>all.equal</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>Pdf_okay</span><span class='op'>$</span><span class='fu'>to_data_frame</span><span class='op'>(</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>Pdf_best</span><span class='op'>$</span><span class='fu'>to_data_frame</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#a user might write it as a one-liner like so:</span></span></span>
<span class='r-in'><span><span class='va'>Pdf_best2</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lazy_csv_reader</span><span class='op'>(</span><span class='va'>temp_filepath</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>filter</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Species"</span><span class='op'>)</span> <span class='op'>==</span> <span class='st'>"setosa"</span><span class='op'>)</span></span></span>
 </code></pre>