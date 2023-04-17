# `ExprStr_ljust`

ljust


## Description

Return the string left justified in a string of length `width` .


## Arguments

Argument      |Description
------------- |----------------
`width`     |     Justify left to this length.
`fillchar`     |     Fill with this ASCII character.


## Details

Padding is done using the specified `fillchar` . The original string is returned if
 `width` is less than or equal to `len(s)` .


## Value

Expr of Utf8


## Examples

```r
df = pl$DataFrame(a = c("cow", "monkey", NA, "hippopotamus"))
df$select(pl$col("a")$str$ljust(8, "*"))
```


