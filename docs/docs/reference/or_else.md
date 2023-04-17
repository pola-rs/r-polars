# `or_else`

map an Err part of Result


## Description

map an Err part of Result


## Usage

```r
or_else(x, f)
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     any R object
`f`     |     a closure that takes the ok part as input, must return a result itself


## Value

same R object wrapped in a Err-result


