# `sum`

Sum

## Description

Reduce Series with sum

## Format

An object of class `character` of length 1.

## Usage

```r
Series_sum
```

## Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to
Int64 before summing to prevent overflow issues.

## Value

Series

## Examples

```r
pl$Series(c(1:2,NA,3,5))$sum() # a NA is dropped always
pl$Series(c(1:2,NA,3,NaN,4,Inf))$sum() # NaN carries / poisons
pl$Series(c(1:2,3,Inf,4,-Inf,5))$sum() # Inf-Inf is NaN
```


