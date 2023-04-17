# `std`

Get the standard deviation of this Series.

## Description

Get the standard deviation of this Series.

## Format

method

## Usage

```r
Series_std(ddof = 1)
```

## Arguments

| Argument | Description                                                                                                                                   | 
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `ddof`         | "Delta Degrees of Freedom": the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1. | 

## Value

bool

## Examples

```r
pl$Series(1:4,"bob")$std()
```


