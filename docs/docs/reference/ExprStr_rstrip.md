# rstrip

## Arguments

- `matches`: The set of characters to be removed. All combinations of this set of characters will be stripped. If set to NULL (default), all whitespace is removed instead.

## Returns

Expr of Utf8 lowercase chars

Remove leading characters.

## Details

will not strip anyt chars beyond the first char not matched. `strip()` starts from both left and right. Whereas `rstrip()`and `rstrip()` starts from left and right respectively.

## Examples

```r
df = pl$DataFrame(foo = c(" hello", "\tworld"))
df$select(pl$col("foo")$str$strip())
df$select(pl$col("foo")$str$strip(" hel rld"))
df$select(pl$col("foo")$str$lstrip(" hel rld"))
df$select(pl$col("foo")$str$rstrip(" hel\trld"))
df$select(pl$col("foo")$str$rstrip("rldhel\t "))
```