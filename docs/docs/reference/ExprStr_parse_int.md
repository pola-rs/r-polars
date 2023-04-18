# parse_int

## Arguments

- `radix`: Positive integer which is the base of the string we are parsing. Default: 2

## Returns

Expr: Series of dtype i32.

Parse integers with base radix from strings. By default base 2.

## Examples

```r
df = pl$DataFrame(bin = c("110", "101", "010"))
df$select(pl$col("bin")$str$parse_int(2))
```