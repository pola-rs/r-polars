# replace

## Arguments

- `pattern`: Into  , regex pattern
- `value`: Into  replcacement
- `literal`: bool, Treat pattern as a literal string.

## Returns

Expr of Utf8 Series

Replace first matching regex/literal substring with a new string value.

## Examples

```r
df = pl$DataFrame(id = c(1, 2), text = c("123abc", "abc456"))
df$with_columns(
   pl$col("text")$str$replace(r"{abc\b}", "ABC")
)
```

## See Also

replace_all : Replace all matching regex/literal substrings.