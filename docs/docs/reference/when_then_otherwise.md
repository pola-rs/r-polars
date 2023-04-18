# when-then-otherwise Expr

## Arguments

- `predicate`: Into Expr into a boolean mask to branch by
- `expr`: Into Expr value to insert in when() or otherwise()

## Returns

Expr

Start a “when, then, otherwise” expression.

## Details

For the impl nerds: pl$when returns a whenthen object and whenthen returns whenthenthen, except for otherwise(), which will terminate and return an Expr. Otherwise may fail to return an Expr if e.g. two consecutive `when(x)$when(y)`

## Examples

```r
df = pl$DataFrame(mtcars)
  wtt =
    pl$when(pl$col("cyl")<=4)$then("<=4cyl")$
    when(pl$col("cyl")<=6)$then("<=6cyl")$
    otherwise(">6cyl")$alias("cyl_groups")
  print(wtt)
  df$with_columns(wtt)
```