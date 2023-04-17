# `print.LazyFrame`

print LazyFrame s3 method


## Description

print LazyFrame s3 method


## Usage

```r
list(list("print"), list("LazyFrame"))(x, ...)
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     DataFrame
`...`     |     not used


## Value

self


## Examples

```r
print(pl$DataFrame(iris)$lazy())
```


