# `min`

min

## Description

Reduce Series with min

## Format

An object of class `character` of length 1.

## Usage

```r
Series_min
```

## Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to
Int64 before minming to prevent overflow issues.

## Value

Series

## Examples

```r
pl$Series(c(1:2,NA,3,5))$min() # a NA is dropped always
pl$Series(c(1:2,NA,3,NaN,4,Inf))$min() # NaN carries / poisons
pl$Series(c(1:2,3,Inf,4,-Inf,5))$min() # Inf-Inf is NaN
```


