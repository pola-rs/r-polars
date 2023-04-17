# `null_count`

GroupBy null count

## Description

Create a new DataFrame that shows the null counts per column.

## Usage

```r
GroupBy_null_count()
```

## Value

DataFrame

## Examples

```r
x = mtcars
x[1:10, 3:5] = NA
pl$DataFrame(x)$groupby("cyl")$null_count()
```


