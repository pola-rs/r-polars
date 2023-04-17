# `ExprStr_explode`

explode


## Description

Returns a column with a separate row for every string character.


## Value

Expr: Series of dtype Utf8.


## Examples

```r
df = pl$DataFrame(a = c("foo", "bar"))
df$select(pl$col("a")$str$explode())
```


