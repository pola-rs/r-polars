# `mean`

Mean

## Description

Aggregate the columns in the DataFrame to their mean value.

## Format

function

## Usage

```r
LazyFrame_mean
```

## Value

A new `LazyFrame` object with applied aggregation.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$mean()$collect()
```


