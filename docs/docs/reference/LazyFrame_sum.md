# `sum`

Sum

## Description

Aggregate the columns of this DataFrame to their sum values.

## Format

function

## Usage

```r
LazyFrame_sum
```

## Value

LazyFrame

## Examples

```r
pl$DataFrame(mtcars)$lazy()$sum()$collect()
```


