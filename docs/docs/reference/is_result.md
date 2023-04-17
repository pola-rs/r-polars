# `is_result`

check if z is a result


## Description

check if z is a result


## Usage

```r
is_result(x)
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     R object which could be a rust-like result of a list with two elements, ok and err


## Details

both ok and err being NULL encodes ok-value NULL. No way to encode an err-value NULL
 If both ok and err has value then this is an invalid result


## Value

bool if is a result object


