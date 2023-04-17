# `pstop`

Internal preferred function to throw errors


## Description

DEPRECATED USE stopf instead


## Usage

```r
pstop(err, call = sys.call(1L))
```


## Arguments

Argument      |Description
------------- |----------------
`err`     |     error msg string
`call`     |     calling context


## Value

throws an error


## Examples

```r
f = function() polars:::pstop("this aint right!!")
tryCatch(f(), error = \(e) as.character(e))
```


