# `lazy`

New LazyFrame from DataFrame\_object$lazy()

## Description

Start a new lazy query from a DataFrame

## Format

An object of class `character` of length 1.

## Usage

```r
DataFrame_lazy
```

## Value

a LazyFrame

## Examples

```r
pl$DataFrame(iris)$lazy()

#use of lazy method
pl$DataFrame(iris)$lazy()$filter(pl$col("Sepal.Length") >= 7.7)$collect()
```


