# `ExprStr_parse_int`

parse_int


## Description

Parse integers with base radix from strings.
 By default base 2.


## Arguments

Argument      |Description
------------- |----------------
`radix`     |     Positive integer which is the base of the string we are parsing. Default: 2


## Value

Expr: Series of dtype i32.


## Examples

```r
df = pl$DataFrame(bin = c("110", "101", "010"))
df$select(pl$col("bin")$str$parse_int(2))
```


