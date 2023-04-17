# `unwrap`

rust-like unwrapping of result. Useful to keep error handling on the R side.


## Description

rust-like unwrapping of result. Useful to keep error handling on the R side.


## Usage

```r
unwrap(result, context = NULL, call = sys.call(1L))
```


## Arguments

Argument      |Description
------------- |----------------
`result`     |     a list here either element ok or err is NULL, or both if ok is litteral NULL
`context`     |     a msg to prefix a raised error with
`call`     |     context of error or string


## Value

the ok-element of list , or a error will be thrown


## Examples

```r
structure(list(ok = "foo", err = NULL), class = "extendr_result")

tryCatch(
unwrap(
structure(
list(ok = NULL, err = "something happen on the rust side"),
class = "extendr_result"
)
),
error = function(err) as.character(err)
)
```


