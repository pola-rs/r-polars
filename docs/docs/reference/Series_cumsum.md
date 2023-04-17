# `cumsum`

Cumulative sum

## Description

Get an array with the cumulative sum computed at every element.

## Usage

```r
Series_cumsum(reverse = FALSE)
```

## Arguments

| Argument | Description                                                      | 
| -------- | ---------------------------------------------------------------- |
| `reverse`         | bool, default FALSE, if true roll over vector from back to forth | 

## Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to
Int64 before summing to prevent overflow issues.

## Value

Series

## Examples

```r
pl$Series(c(1:2,NA,3,NaN,4,Inf))$cumsum()
pl$Series(c(1:2,NA,3,Inf,4,-Inf,5))$cumsum()
```


