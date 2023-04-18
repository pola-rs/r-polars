# Concat

## Arguments

- `delimiter`: string The delimiter to insert between consecutive string values.

## Returns

Expr of Utf8 concatenated

Vertically concat the values in the Series to a single string value.

## Examples

```r
#concatenate a Series of strings to a single string
df = pl$DataFrame(foo = c("1", NA, 2))
df$select(pl$col("foo")$str$concat("-"))

#Series list of strings to Series of concatenated strings
df = pl$DataFrame(list(bar = list(c("a","b", "c"), c("1","2",NA))))
df$select(pl$col("bar")$arr$eval(pl$col()$str$concat())$arr$first())
```