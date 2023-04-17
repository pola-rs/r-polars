# `print`

print LazyFrame internal method

## Description

can be used i the middle of a method chain

## Format

An object of class `character` of length 1.

## Usage

```r
LazyFrame_print(x)
```

## Arguments

| Argument | Description | 
| -------- | ----------- |
| `x`         | LazyFrame   | 

## Value

self

## Examples

```r
pl$DataFrame(iris)$lazy()$print()
```


