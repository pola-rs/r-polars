# `dtype`

Get data type of Series

## Description

Get data type of Series

Get data type of Series

## Usage

```r
Series_dtype()
Series_flags()
```

## Details

property sorted flags are not settable, use set\_sorted

## Value

DataType

DataType

## Examples

```r
pl$Series(1:4)$dtype
pl$Series(c(1,2))$dtype
pl$Series(letters)$dtype
pl$Series(1:4)$sort()$flags
```


