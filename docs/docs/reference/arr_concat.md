# concat another list

## Format

function

## Arguments

- `other`: Rlist, Expr or column of same tyoe as self.

## Returns

Expr

Concat the arrays in a Series dtype List in linear time.

## Examples

```r
df = pl$DataFrame(
  a = list("a","x"),
  b = list(c("b","c"),c("y","z"))
)
df$select(pl$col("a")$arr$concat(pl$col("b")))

df$select(pl$col("a")$arr$concat("hello from R"))

df$select(pl$col("a")$arr$concat(list("hello",c("hello","world"))))
```