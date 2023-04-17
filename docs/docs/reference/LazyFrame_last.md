# `last`

Last

## Description

Aggregate the columns in the DataFrame to their maximum value.

## Format

function

## Usage

```r
LazyFrame_last
```

## Value

A new `LazyFrame` object with applied aggregation.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$last()$collect()
```


