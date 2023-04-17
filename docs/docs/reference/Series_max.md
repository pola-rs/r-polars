# `max`

max

## Description

Reduce Series with max

## Format

An object of class `character` of length 1.

## Usage

```r
Series_max
```

## Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to
Int64 before maxming to prevent overflow issues.

## Value

Series

## Examples

```r
pl$Series(c(1:2,NA,3,5))$max() # a NA is dropped always
pl$Series(c(1:2,NA,3,NaN,4,Inf))$max() # NaN carries / poisons
pl$Series(c(1:2,3,Inf,4,-Inf,5))$max() # Inf-Inf is NaN
```


