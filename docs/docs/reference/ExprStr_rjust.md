# rjust

## Arguments

- `width`: Justify left to this length.
- `fillchar`: Fill with this ASCII character.

## Returns

Expr of Utf8

Return the string left justified in a string of length `width`.

## Details

Padding is done using the specified `fillchar`. The original string is returned if `width` is less than or equal to `len(s)`.

## Examples

```r
df = pl$DataFrame(a = c("cow", "monkey", NA, "hippopotamus"))
df$select(pl$col("a")$str$rjust(8, "*"))
```