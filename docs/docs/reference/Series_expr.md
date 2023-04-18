# Any expr method on a Series

```r
Series_expr()
```

## Returns

Expr

Call an expression on a Series See the individual Expr method pages for full details

## Details

This is a shorthand of writing something like `pl$DataFrame(s)$select(pl$col("sname")$expr)$to_series(0)`

This subnamespace is experimental. Submit an issue if anything unexpected happend.

## Examples

```r
s = pl$Series(list(1:3,1:2,NULL))
s$expr$first()
s$expr$alias("alice")
```