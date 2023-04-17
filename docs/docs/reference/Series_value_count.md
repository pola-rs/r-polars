# `value_count`

Value Counts as DataFrame

## Description

Value Counts as DataFrame

## Usage

```r
Series_value_counts(sorted = TRUE, multithreaded = FALSE)
```

## Arguments

| Argument | Description                                                                                                                                                                                                                              | 
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sorted`         | bool, default TRUE: sort table by value; FALSE: random                                                                                                                                                                                   | 
| `multithreaded`         | bool, default FALSE, process multithreaded. Likely faster to have TRUE for a big Series. If called within an already multithreaded context such calling apply on a GroupBy with many groups, then likely slightly faster to leave FALSE. | 

## Value

DataFrame

## Examples

```r
pl$Series(iris$Species,"flower species")$value_counts()
```


