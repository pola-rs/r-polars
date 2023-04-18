# GroupBy null count

```r
GroupBy_null_count()
```

## Returns

DataFrame

Create a new DataFrame that shows the null counts per column.

## Examples

```r
x = mtcars
x[1:10, 3:5] = NA
pl$DataFrame(x)$groupby("cyl")$null_count()
```