# `std`

Std

## Description

Aggregate the columns of this DataFrame to their standard deviation values.

## Usage

```r
DataFrame_std(ddof = 1)
```

## Arguments

| Argument | Description                                                                                                                                         | 
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ddof`         | integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1. | 

## Value

A new `DataFrame` object with applied aggregation.

## Examples

```r
pl$DataFrame(mtcars)$std()
```


