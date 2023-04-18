# Null count

## Format

function

```r
DataFrame_null_count
```

## Returns

DataFrame

Create a new DataFrame that shows the null counts per column.

## Examples

```r
x = mtcars
x[1, 2:3] = NA
pl$DataFrame(x)$null_count()
```