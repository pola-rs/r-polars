# Simple viewer of an R object based on str()

```r
str_string(x, collapse = " ")
```

## Arguments

- `x`: object to view.
- `collapse`: word to glue possible multilines with

## Returns

string

Simple viewer of an R object based on str()

## Examples

```r
polars:::str_string(list(a=42,c(1,2,3,NA)))
```