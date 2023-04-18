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

```r
library(nanoarrow)
df = pl$DataFrame(mtcars)
nanoarrow_array_stream = as_nanoarrow_array_stream(df)
rdf = as.data.frame(nanoarrow_array_stream)
print(head(rdf))
nanoarrow_array_schema = infer_nanoarrow_schema(df)
print(nanoarrow_array_schema)
library(arrow)
arrow_table = as_arrow_table(df)
print(arrow_table)
arrow_record_batch_reader = as_record_batch_reader(df) #requires arrow
print(arrow_record_batch_reader)
```