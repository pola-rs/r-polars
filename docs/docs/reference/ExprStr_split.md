# `ExprStr_split`

split


## Description

Split the string by a substring.


## Arguments

Argument      |Description
------------- |----------------
`by`     |     Substring to split by.
`inclusive`     |     If True, include the split character/string in the results.


## Value

List of Utf8 type


## Examples

```r
df = pl$DataFrame(s = c("foo bar", "foo-bar", "foo bar baz"))
df$select( pl$col("s")$str$split(by=" "))
```


