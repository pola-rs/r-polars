# `print.WhenThen`

print When


## Description

print When


## Usage

```r
list(list("print"), list("WhenThen"))(x, ...)
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     When object
`...`     |     not used


## Value

self


## Examples

```r
print(pl$when(pl$col("a")>2)$then(pl$lit("more than two")))
```


