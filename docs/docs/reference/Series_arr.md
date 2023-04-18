# arr: list related methods on Series of dtype List

```r
Series_arr()
```

## Returns

Expr

Create an object namespace of all list related methods. See the individual method pages for full details

## Examples

```r
s = pl$Series(list(1:3,1:2,NULL))
s
s$arr$first()
```