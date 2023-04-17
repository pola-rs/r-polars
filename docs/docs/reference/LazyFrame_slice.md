# `slice`

Slice

## Description

Get a slice of this DataFrame.

## Usage

```r
LazyFrame_slice(offset, length = NULL)
```

## Arguments

| Argument | Description     | 
| -------- | --------------- |
| `offset`         | integer         | 
| `length`         | integer or NULL | 

## Value

DataFrame

## Examples

```r
pl$DataFrame(mtcars)$lazy()$slice(2, 4)$collect()
pl$DataFrame(mtcars)$lazy()$slice(30)$collect()
mtcars[2:6,]
```


