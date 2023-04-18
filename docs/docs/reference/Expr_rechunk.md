data

# Rechunk memory layout

## Format

a method

```r
Expr_rechunk
```

## Returns

Expr

Create a single chunk of memory for this Series.

## Details

See rechunk() explained here `docs_translations`

## Examples

```r
#get chunked lengths with/without rechunk
series_list = pl$DataFrame(list(a=1:3,b=4:6))$select(
  pl$col("a")$append(pl$col("b"))$alias("a_chunked"),
  pl$col("a")$append(pl$col("b"))$rechunk()$alias("a_rechunked")
)$get_columns()
lapply(series_list, \(x) x$chunk_lengths())
```