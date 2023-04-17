# `is_sorted`

is\_sorted

## Description

is\_sorted

## Usage

```r
Series_is_sorted(reverse = FALSE, nulls_last = NULL)
```

## Arguments

| Argument | Description                                       | 
| -------- | ------------------------------------------------- |
| `reverse`         | order sorted                                      | 
| `nulls_last`         | bool where to keep nulls, default same as reverse | 

## Details

property sorted flags are not settable, use set\_sorted

## Value

DataType

## Examples

```r
pl$Series(1:4)$sort()$is_sorted()
```


