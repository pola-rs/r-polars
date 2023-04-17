# `ExprStr_extract_all`

extract_all


## Description

Extracts all matches for the given regex pattern. Extracts each successive
 non-overlapping regex match in an individual string as an array.


## Arguments

Argument      |Description
------------- |----------------
`pattern`     |     A valid regex pattern


## Value

`List[Utf8]` array. Contain null if original value is null or regex capture nothing.


## Examples

```r
df = pl$DataFrame( foo = c("123 bla 45 asd", "xyz 678 910t"))
df$select(
pl$col("foo")$str$extract_all(r"((\d+))")$alias("extracted_nrs")
)
```


