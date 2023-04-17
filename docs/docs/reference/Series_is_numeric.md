# `is_numeric`

is\_numeric

## Description

return bool whether series is numeric

## Format

method

## Usage

```r
Series_is_numeric()
```

## Details

true of series dtype is member of pl$numeric\_dtypes

## Value

bool

## Examples

```r
pl$Series(1:4)$is_numeric()
pl$Series(c("a","b","c"))$is_numeric()
pl$numeric_dtypes
```


