# `min`

Min

## Description

Aggregate the columns in the DataFrame to their minimum value.

## Format

function

## Usage

```r
LazyFrame_min
```

## Value

A new `LazyFrame` object with applied aggregation.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$min()$collect()
```


