# polars to nanoarrow and arrow

```r
as_nanoarrow_array_stream.DataFrame(x, ..., schema = NULL)

infer_nanoarrow_schema.DataFrame(x, ...)

as_arrow_table.DataFrame(x, ...)

as_record_batch_reader.DataFrame(x, ..., schema = NULL)
```

## Arguments

- `x`: a polars DataFrame
- `...`: not used right now
- `schema`: must stay at default value NULL

## Returns

 * a nanoarrow array stream

 * a nanoarrow array schema

 * an arrow table

 * an arrow record batch reader

Conversion via native apache arrow array stream (fast), THIS REQUIRES ´nanoarrow´

## Details

The following functions enable conversion to `nanoarrow` and `arrow`. Conversion kindly provided by "paleolimbot / Dewey Dunnington" Author of `nanoarrow`. Currently these conversions are the fastest way to convert from polars to R.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='kw'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='op'>(</span><span class='va'><a href='https://github.com/apache/arrow-nanoarrow'>nanoarrow</a></span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>nanoarrow_array_stream</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/pkg/nanoarrow/man/as_nanoarrow_array_stream.html'>as_nanoarrow_array_stream</a></span><span class='op'>(</span><span class='va'>df</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>rdf</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.data.frame.html'>as.data.frame</a></span><span class='op'>(</span><span class='va'>nanoarrow_array_stream</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='op'>(</span><span class='va'>rdf</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>    mpg cyl disp  hp drat    wt  qsec vs am gear carb</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 1 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 2 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 3 22.8   4  108  93 3.85 2.320 18.61  1  1    4    1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 4 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 5 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 6 18.1   6  225 105 2.76 3.460 20.22  1  0    3    1</span>
<span class='r-in'><span><span class='va'>nanoarrow_array_schema</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/pkg/nanoarrow/man/as_nanoarrow_schema.html'>infer_nanoarrow_schema</a></span><span class='op'>(</span><span class='va'>df</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>nanoarrow_array_schema</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;nanoarrow_schema struct&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  $ format    : chr "+s"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  $ name      : chr ""</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  $ metadata  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  $ flags     : int 0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  $ children  :List of 11</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   ..$ mpg :&lt;nanoarrow_schema double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ format    : chr "g"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ name      : chr "mpg"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ metadata  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ flags     : int 2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ children  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ dictionary: NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   ..$ cyl :&lt;nanoarrow_schema double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ format    : chr "g"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ name      : chr "cyl"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ metadata  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ flags     : int 2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ children  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ dictionary: NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   ..$ disp:&lt;nanoarrow_schema double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ format    : chr "g"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ name      : chr "disp"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ metadata  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ flags     : int 2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ children  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ dictionary: NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   ..$ hp  :&lt;nanoarrow_schema double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ format    : chr "g"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ name      : chr "hp"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ metadata  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ flags     : int 2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ children  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ dictionary: NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   ..$ drat:&lt;nanoarrow_schema double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ format    : chr "g"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ name      : chr "drat"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ metadata  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ flags     : int 2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ children  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ dictionary: NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   ..$ wt  :&lt;nanoarrow_schema double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ format    : chr "g"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ name      : chr "wt"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ metadata  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ flags     : int 2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ children  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ dictionary: NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   ..$ qsec:&lt;nanoarrow_schema double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ format    : chr "g"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ name      : chr "qsec"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ metadata  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ flags     : int 2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ children  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ dictionary: NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   ..$ vs  :&lt;nanoarrow_schema double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ format    : chr "g"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ name      : chr "vs"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ metadata  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ flags     : int 2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ children  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ dictionary: NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   ..$ am  :&lt;nanoarrow_schema double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ format    : chr "g"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ name      : chr "am"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ metadata  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ flags     : int 2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ children  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ dictionary: NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   ..$ gear:&lt;nanoarrow_schema double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ format    : chr "g"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ name      : chr "gear"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ metadata  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ flags     : int 2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ children  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ dictionary: NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   ..$ carb:&lt;nanoarrow_schema double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ format    : chr "g"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ name      : chr "carb"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ metadata  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ flags     : int 2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ children  : list()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   .. ..$ dictionary: NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  $ dictionary: NULL</span>
<span class='r-in'><span><span class='kw'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='op'>(</span><span class='va'><a href='https://github.com/apache/arrow/'>arrow</a></span><span class='op'>)</span></span></span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> Attaching package: ‘arrow’</span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> The following object is masked from ‘package:testthat’:</span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span>     matches</span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> The following object is masked from ‘package:magrittr’:</span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span>     is_in</span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> The following object is masked from ‘package:utils’:</span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span>     timestamp</span>
<span class='r-in'><span><span class='va'>arrow_table</span> <span class='op'>=</span> <span class='fu'><a href='https://arrow.apache.org/docs/r/reference/as_arrow_table.html'>as_arrow_table</a></span><span class='op'>(</span><span class='va'>df</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>arrow_table</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Table</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 32 rows x 11 columns</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $mpg &lt;double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $cyl &lt;double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $disp &lt;double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $hp &lt;double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $drat &lt;double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $wt &lt;double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $qsec &lt;double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $vs &lt;double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $am &lt;double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $gear &lt;double&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $carb &lt;double&gt;</span>
<span class='r-in'><span><span class='va'>arrow_record_batch_reader</span> <span class='op'>=</span> <span class='fu'><a href='https://arrow.apache.org/docs/r/reference/as_record_batch_reader.html'>as_record_batch_reader</a></span><span class='op'>(</span><span class='va'>df</span><span class='op'>)</span> <span class='co'>#requires arrow</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>arrow_record_batch_reader</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> RecordBatchReader</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> mpg: double</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> cyl: double</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> disp: double</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> hp: double</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> drat: double</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> wt: double</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> qsec: double</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> vs: double</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> am: double</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> gear: double</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> carb: double</span>
 </code></pre>