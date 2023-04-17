# `ExprStr_splitn`

splitn


## Description

Split the string by a substring, restricted to returning at most `n` items.
 If the number of possible splits is less than `n-1` , the remaining field
 elements will be null. If the number of possible splits is `n-1` or greater,
 the last (nth) substring will contain the remainder of the string.


## Arguments

Argument      |Description
------------- |----------------
`by`     |     Substring to split by.
`n`     |     Number of splits to make.


## Value

Struct where each of n+1 fields is of Utf8 type


## Examples

```r
df = pl$DataFrame(s = c("a_1", NA, "c", "d_4"))
df$select( pl$col("s")$str$splitn(by="_",0))
df$select( pl$col("s")$str$splitn(by="_",1))
df$select( pl$col("s")$str$splitn(by="_",2))
```


