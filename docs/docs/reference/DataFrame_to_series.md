# `to_series`

Get Series by idx, if there

## Description

get one column by idx as series from DataFrame.
Unlike get\_column this method will not fail if no series found at idx but
return a NULL, idx is zero idx.

## Usage

```r
DataFrame_to_series(idx = 0)
```

## Arguments

| Argument | Description                                                      | 
| -------- | ---------------------------------------------------------------- |
| `idx`         | numeric default 0, zero-index of what column to return as Series | 

## Value

Series or NULL

## Examples

```r
pl$DataFrame(a=1:4)$to_series()
```


