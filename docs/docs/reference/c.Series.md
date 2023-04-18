# Immutable combine series

```r
## S3 method for class 'Series'
c(x, ...)
```

## Arguments

- `x`: a Series
- `...`: Series(s) or any object into Series meaning `pl$Series(object)` returns a series

## Returns

a combined Series

Immutable combine series

## Details

append datatypes has to match. Combine does not rechunk. Read more about R vectors, Series and chunks in `docs_translations`:

## Examples

```r
s = c(pl$Series(1:5),3:1,NA_integer_)
s$chunk_lengths() #the series contain three unmerged chunks
```