# `rename`

Rename a series

## Description

Rename a series

## Format

method

## Usage

```r
Series_rename(name, in_place = FALSE)
```

## Arguments

| Argument | Description                                                                                             | 
| -------- | ------------------------------------------------------------------------------------------------------- |
| `name`         | string the new name                                                                                     | 
| `in_place`         | bool rename in-place, breaks immutability If true will throw an error unless this option has been set: `pl$set_polars_options(strictly_immutable = FALSE)` | 

## Value

bool

## Examples

```r
pl$Series(1:4,"bob")$rename("alice")
```


