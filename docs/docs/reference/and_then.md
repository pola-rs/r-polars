# `and_then`

map an ok-value or pass on an err-value


## Description

map an ok-value or pass on an err-value


## Usage

```r
and_then(x, f)
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     any R object
`f`     |     a closure that takes the ok part as input


## Value

same R object wrapped in a Err-result


