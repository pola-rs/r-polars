# `first`

First

## Description

Get the first row of the DataFrame.

## Format

function

## Usage

```r
LazyFrame_first
```

## Value

A new `DataFrame` object with applied filter.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$first()$collect()
```


