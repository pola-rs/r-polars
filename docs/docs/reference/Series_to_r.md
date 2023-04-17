# `to_r`

Get r vector/list

## Description

return R list (if polars Series is list)  or vector (any other polars Series type)

return R vector (implicit unlist)

return R list (implicit as.list)

## Usage

```r
Series_to_r()
Series_to_r_vector()
Series_to_r_list()
```

## Details

Fun fact: Nested polars Series list must have same inner type, e.g. List(List(Int32))
Thus every leaf(non list type) will be placed on the same depth of the tree, and be the same type.

## Value

R list or vector

R vector

R list

## Examples

```r
#make polars Series_Utf8
series_vec = pl$Series(letters[1:3])

#Series_non_list
series_vec$to_r() #as vector because Series DataType is not list (is Utf8)
series_vec$to_r_list() #implicit call as.list(), convert to list
series_vec$to_r_vector() #implicit call unlist(), same as to_r() as already vector


#make nested Series_list of Series_list of Series_Int32
#using Expr syntax because currently more complete translated
series_list = pl$DataFrame(list(a=c(1:5,NA_integer_)))$select(
pl$col("a")$list()$list()$append(
(
pl$col("a")$head(2)$list()$append(
pl$col("a")$tail(1)$list()
)
)$list()
)
)$get_column("a") # get series from DataFrame

#Series_list
series_list$to_r() #as list because Series DataType is list
series_list$to_r_list() #implicit call as.list(), same as to_r() as already list
series_list$to_r_vector() #implicit call unlist(), append into a vector
#
#
```


