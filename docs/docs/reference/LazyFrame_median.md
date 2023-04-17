# `median`

Median

## Description

Aggregate the columns in the DataFrame to their median value.

## Format

function

## Usage

```r
LazyFrame_median
```

## Value

A new `LazyFrame` object with applied aggregation.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$median()$collect()
```


