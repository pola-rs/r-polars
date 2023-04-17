# `var`

Var

## Description

Aggregate the columns of this LazyFrame to their variance values.

## Usage

```r
LazyFrame_var(ddof = 1)
```

## Arguments

| Argument | Description                                                                                                                                         | 
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ddof`         | integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1. | 

## Value

A new `LazyFrame` object with applied aggregation.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$var()$collect()
```


