# polars to nanoarrow and arrow

*Source: [R/pkg-nanoarrow.R](https://github.com/pola-rs/r-polars/tree/main/R/pkg-nanoarrow.R)*

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

<pre class='r-example'><code><span class='r-in'><span><span class='kw'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='op'>(</span><span class='va'><a href='https://github.com/apache/arrow-nanoarrow'>nanoarrow</a></span><span class='op'>)</span></span></span>
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in library(nanoarrow):</span> aucun package nommé ‘nanoarrow’ n'est trouvé</span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>nanoarrow_array_stream</span> <span class='op'>=</span> <span class='fu'>as_nanoarrow_array_stream</span><span class='op'>(</span><span class='va'>df</span><span class='op'>)</span></span></span>
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in as_nanoarrow_array_stream(df):</span> impossible de trouver la fonction "as_nanoarrow_array_stream"</span>
<span class='r-in'><span><span class='va'>rdf</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/as.data.frame.html'>as.data.frame</a></span><span class='op'>(</span><span class='va'>nanoarrow_array_stream</span><span class='op'>)</span></span></span>
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in as.data.frame(nanoarrow_array_stream):</span> objet 'nanoarrow_array_stream' introuvable</span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='op'>(</span><span class='va'>rdf</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in head(rdf):</span> objet 'rdf' introuvable</span>
<span class='r-in'><span><span class='va'>nanoarrow_array_schema</span> <span class='op'>=</span> <span class='fu'>infer_nanoarrow_schema</span><span class='op'>(</span><span class='va'>df</span><span class='op'>)</span></span></span>
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in infer_nanoarrow_schema(df):</span> impossible de trouver la fonction "infer_nanoarrow_schema"</span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>nanoarrow_array_schema</span><span class='op'>)</span></span></span>
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in print(nanoarrow_array_schema):</span> objet 'nanoarrow_array_schema' introuvable</span>
<span class='r-in'><span><span class='kw'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='op'>(</span><span class='va'><a href='https://github.com/apache/arrow/'>arrow</a></span><span class='op'>)</span></span></span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> Attachement du package : ‘arrow’</span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> L'objet suivant est masqué depuis ‘package:testthat’:</span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span>     matches</span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> L'objet suivant est masqué depuis ‘package:magrittr’:</span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span>     is_in</span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> L'objet suivant est masqué depuis ‘package:utils’:</span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-msg co'><span class='r-pr'>#&gt;</span>     timestamp</span>
<span class='r-in'><span><span class='va'>arrow_table</span> <span class='op'>=</span> <span class='fu'><a href='https://arrow.apache.org/docs/r/reference/as_arrow_table.html'>as_arrow_table</a></span><span class='op'>(</span><span class='va'>df</span><span class='op'>)</span></span></span>
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in loadNamespace(x):</span> aucun package nommé ‘nanoarrow’ n'est trouvé</span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>arrow_table</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> function (..., schema = NULL) </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     dots &lt;- list2(...)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     if (is.null(names(dots))) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         names(dots) &lt;- rep_len("", length(dots))</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     if (length(dots) == 0 &amp;&amp; inherits(schema, "Schema")) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         return(Table__from_schema(schema))</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     stopifnot(length(dots) &gt; 0)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     if (all_record_batches(dots)) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         return(Table__from_record_batches(dots, schema))</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     if (length(dots) == 1 &amp;&amp; inherits(dots[[1]], c("RecordBatchReader", </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         "RecordBatchFileReader"))) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         tab &lt;- dots[[1]]$read_table()</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         if (!is.null(schema)) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             tab &lt;- tab$cast(schema)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         return(tab)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     dots &lt;- recycle_scalars(dots)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     Table__from_dots(dots, schema, option_use_threads())</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;bytecode: 0x5644b1a04388&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;environment: namespace:arrow&gt;</span>
<span class='r-in'><span><span class='va'>arrow_record_batch_reader</span> <span class='op'>=</span> <span class='fu'><a href='https://arrow.apache.org/docs/r/reference/as_record_batch_reader.html'>as_record_batch_reader</a></span><span class='op'>(</span><span class='va'>df</span><span class='op'>)</span> <span class='co'>#requires arrow</span></span></span>
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in loadNamespace(x):</span> aucun package nommé ‘nanoarrow’ n'est trouvé</span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>arrow_record_batch_reader</span><span class='op'>)</span></span></span>
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in print(arrow_record_batch_reader):</span> objet 'arrow_record_batch_reader' introuvable</span>
 </code></pre>