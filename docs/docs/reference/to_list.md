# return polars DataFrame as R lit of vectors

```r
DataFrame_to_list(unnest_structs = TRUE)
```

## Arguments

- `unnest_structs`: bool default true, as calling $unnest() on any struct column

## Returns

R list of vectors

return polars DataFrame as R lit of vectors

## Details

This implementation for simplicity reasons relies on unnesting all structs before exporting to R. unnest_structs = FALSE, the previous struct columns will be re- nested. A struct in a R is a lists of lists, where each row is a list of values. Such a structure is not very typical or efficient in R.

## Examples

```r
pl$DataFrame(iris)$to_list()
```