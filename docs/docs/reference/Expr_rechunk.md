# `Expr_rechunk`

Rechunk memory layout


## Description

Create a single chunk of memory for this Series.


## Format

a method


## Usage

```r
Expr_rechunk
```


## Details

See rechunk() explained here [`docs_translations`](#docstranslations)


## Value

Expr


## Examples

```r
#get chunked lengths with/without rechunk
series_list = pl$DataFrame(list(a=1:3,b=4:6))$select(
pl$col("a")$append(pl$col("b"))$alias("a_chunked"),
pl$col("a")$append(pl$col("b"))$rechunk()$alias("a_rechunked")
)$get_columns()
lapply(series_list, \(x) x$chunk_lengths())
```


