# zfill

## Arguments

- `alignment`: Fill the value up to this length

## Returns

Expr

Fills the string with zeroes.

## Details

Return a copy of the string left filled with ASCII '0' digits to make a string of length width.

A leading sign prefix ('+'/'-') is handled by inserting the padding after the sign character rather than before. The original string is returned if width is less than or equal to `len(s)`.

## Examples

```r
some_floats_expr = pl$lit(c(0,10,-5,5))

#cast to Utf8 and ljust alignment = 5, and view as R char vector
some_floats_expr$cast(pl$Utf8)$str$zfill(5)$to_r()

#cast to int and the to utf8 and then ljust alignment = 5, and view as R char vector
some_floats_expr$cast(pl$Int64)$cast(pl$Utf8)$str$zfill(5)$to_r()
```