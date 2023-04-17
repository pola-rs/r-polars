# `print.WhenThenThen`

print When


## Description

print When


## Usage

```r
list(list("print"), list("WhenThenThen"))(x, ...)
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
#
print(pl$when(pl$col("a")>2)$then(pl$lit("more than two"))$when(pl$col("b")<5))
```


