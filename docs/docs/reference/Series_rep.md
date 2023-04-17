# `rep`

duplicate and concatenate a series

## Description

duplicate and concatenate a series

## Format

method

## Usage

```r
Series_rep(n, rechunk = TRUE)
```

## Arguments

| Argument | Description                                                                                                                        | 
| -------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `n`         | number of times to repeat                                                                                                          | 
| `rechunk`         | bool default true, reallocate object in memory. If FALSE the Series will take up less space, If TRUE calculations might be faster. | 

## Details

This function in not implemented in pypolars

## Value

bool

## Examples

```r
pl$Series(1:2,"bob")$rep(3)
```


