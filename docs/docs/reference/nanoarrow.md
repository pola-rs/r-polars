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
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in library(arrow):</span> aucun package nommé ‘arrow’ n'est trouvé</span>
<span class='r-in'><span><span class='va'>arrow_table</span> <span class='op'>=</span> <span class='fu'>as_arrow_table</span><span class='op'>(</span><span class='va'>df</span><span class='op'>)</span></span></span>
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in as_arrow_table(df):</span> impossible de trouver la fonction "as_arrow_table"</span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>arrow_table</span><span class='op'>)</span></span></span>
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in print(arrow_table):</span> objet 'arrow_table' introuvable</span>
<span class='r-in'><span><span class='va'>arrow_record_batch_reader</span> <span class='op'>=</span> <span class='fu'>as_record_batch_reader</span><span class='op'>(</span><span class='va'>df</span><span class='op'>)</span> <span class='co'>#requires arrow</span></span></span>
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in as_record_batch_reader(df):</span> impossible de trouver la fonction "as_record_batch_reader"</span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>arrow_record_batch_reader</span><span class='op'>)</span></span></span>
<span class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in print(arrow_record_batch_reader):</span> objet 'arrow_record_batch_reader' introuvable</span>
 </code></pre>