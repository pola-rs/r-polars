# `print.GroupBy`

print GroupBy


## Description

print GroupBy


## Usage

```r
list(list("print"), list("GroupBy"))(x, ...)
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
pl$DataFrame(iris)$groupby("Species")
```


