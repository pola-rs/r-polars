# `slice`

Slice

## Description

Get a slice of this DataFrame.

## Usage

```r
DataFrame_slice(offset, length = NULL)
```

## Arguments

| Argument | Description     | 
| -------- | --------------- |
| `offset`         | integer         | 
| `length`         | integer or NULL | 

## Value

LazyFrame

## Examples

```r
pl$DataFrame(mtcars)$slice(2, 4)
mtcars[2:6,]
```


