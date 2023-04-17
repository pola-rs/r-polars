# `filter()`

filter DataFrame


## Description

DataFrame$filter(bool_expr)


## Usage

```r
DataFrame_filter(bool_expr)
```


## Arguments

Argument      |Description
------------- |----------------
`bool_expr`     |     Polars expression which will evaluate to a bool pl$Series


## Value

filtered DataFrame


## Examples

```r
pl$DataFrame(iris)$lazy()$filter(pl$col("Sepal.Length") > 5)$collect()
```


