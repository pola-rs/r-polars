# `filter`

Apply filter to LazyFrame

## Description

Filter rows with an Expression definining a boolean column

## Format

An object of class `character` of length 1.

## Usage

```r
LazyFrame_filter(expr)
```

## Arguments

| Argument | Description                        | 
| -------- | ---------------------------------- |
| `expr`         | one Expr or string naming a column | 

## Value

A new `LazyFrame` object with add/modified column.

## Examples

```r
pl$DataFrame(iris)$lazy()$filter(pl$col("Species")=="setosa")$collect()
```


