# `null_count`

Null count

## Description

Create a new DataFrame that shows the null counts per column.

## Format

function

## Usage

```r
DataFrame_null_count
```

## Value

DataFrame

## Examples

```r
x = mtcars
x[1, 2:3] = NA
pl$DataFrame(x)$null_count()
```


