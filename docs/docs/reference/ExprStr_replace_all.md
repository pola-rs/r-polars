# replace_all

## Arguments

- `pattern`: Into  , regex pattern
- `value`: Into  replcacement
- `literal`: bool, treat pattern as a literal string.

## Returns

Expr of Utf8 Series

Replace all matching regex/literal substrings with a new string value.

## Examples

```r
df = pl$DataFrame(id = c(1, 2), text = c("abcabc", "123a123"))
df$with_columns(
   pl$col("text")$str$replace_all("a", "-")
)
```

## See Also

replace : Replace first matching regex/literal substring.