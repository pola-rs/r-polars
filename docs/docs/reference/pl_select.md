# `select`

Select from an empty DataFrame

## Description

Select from an empty DataFrame

## Format

method

## Details

param ... expressions passed to select
`pl$select` is a shorthand for `pl$DataFrame(list())$select`

NB param of this function

## Value

DataFrame

## Examples

```r
pl$select(
pl$lit(1:4)$alias("ints"),
pl$lit(letters[1:4])$alias("letters")
)
```


