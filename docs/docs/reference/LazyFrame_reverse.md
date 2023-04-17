# `reverse`

Reverse

## Description

Reverse the DataFrame.

## Format

An object of class `character` of length 1.

## Usage

```r
LazyFrame_reverse
```

## Value

LazyFrame

## Examples

```r
pl$DataFrame(mtcars)$lazy()$reverse()$collect()
```


