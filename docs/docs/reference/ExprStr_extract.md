# `ExprStr_extract`

extract


## Description

Extract the target capture group from provided patterns.


## Arguments

Argument      |Description
------------- |----------------
`pattern`     |     A valid regex pattern
`group_index`     |     Index of the targeted capture group. Group 0 mean the whole pattern, first group begin at index 1. Default to the first capture group.


## Value

Utf8 array. Contain null if original value is null or regex capture nothing.


## Examples

```r
df = pl$DataFrame(
a =  c(
"http://vote.com/ballon_dor?candidate=messi&ref=polars",
"http://vote.com/ballon_dor?candidat=jorginho&ref=polars",
"http://vote.com/ballon_dor?candidate=ronaldo&ref=polars"
)
)
df$select(
pl$col("a")$str$extract(r"(candidate=(\w+))", 1)
)
```


