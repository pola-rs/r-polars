# `limit`

Limits

## Description

take limit of n rows of query

## Usage

```r
LazyFrame_limit(n)
```

## Arguments

| Argument | Description                                             | 
| -------- | ------------------------------------------------------- |
| `n`         | positive numeric or integer number not larger than 2^32 | 

## Details

any number will converted to u32. Negative raises error

## Value

A new `LazyFrame` object with applied filter.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$limit(4)$collect()
```


