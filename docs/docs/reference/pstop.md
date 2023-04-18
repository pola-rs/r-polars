# Internal preferred function to throw errors

```r
pstop(err, call = sys.call(1L))
```

## Arguments

- `err`: error msg string
- `call`: calling context

## Returns

throws an error

DEPRECATED USE stopf instead

## Examples

```r
f = function() polars:::pstop("this aint right!!")
tryCatch(f(), error = \(e) as.character(e))
```