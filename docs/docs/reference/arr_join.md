# `arr_join`

Join sublists


## Description

Join all string items in a sublist and place a separator between them.
 This errors if inner type of list != Utf8 .


## Format

function


## Arguments

Argument      |Description
------------- |----------------
`separator`     |     string to separate the items with


## Value

Series of dtype Utf8


## Examples

```r
df = pl$DataFrame(list(s = list(c("a","b","c"), c("x","y"))))
df$select(pl$col("s")$arr$join(" "))
```


