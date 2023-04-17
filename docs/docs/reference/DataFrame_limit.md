# `limit`

Limit a DataFrame

## Description

take limit of n rows of query

## Usage

```r
DataFrame_limit(n)
```

## Arguments

| Argument | Description                                             | 
| -------- | ------------------------------------------------------- |
| `n`         | positive numeric or integer number not larger than 2^32 | 

## Details

any number will converted to u32. Negative raises error

## Value

DataFrame


