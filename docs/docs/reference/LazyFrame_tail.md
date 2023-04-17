# `tail`

Tail

## Description

take last n rows of query

## Usage

```r
LazyFrame_tail(n)
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
pl$DataFrame(mtcars)$lazy()$tail(2)$collect()
```


