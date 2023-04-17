# `ExprStr_count_match`

count_match


## Description

Count all successive non-overlapping regex matches.


## Arguments

Argument      |Description
------------- |----------------
`pattern`     |     A valid regex pattern


## Value

UInt32 array. Contain null if original value is null or regex capture nothing.


## Examples

```r
df = pl$DataFrame( foo = c("123 bla 45 asd", "xyz 678 910t"))
df$select(
pl$col("foo")$str$count_match(r"{(\d)}")$alias("count digits")
)
```


