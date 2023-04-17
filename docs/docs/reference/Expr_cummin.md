# `Expr_cummin`

Cumulative minimum


## Description

Get an array with the cumulative min computed at every element.
 
 Get an array with the cumulative max computed at every element.


## Format

a method
 
 a method


## Usage

```r
Expr_cummin(reverse = FALSE)
Expr_cummax(reverse = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
`reverse`     |     bool, default FALSE, if true roll over vector from back to forth


## Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to
 Int64 before summing to prevent overflow issues.
 
 See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations) 
 
 Dtypes in Int8, UInt8, Int16, UInt16 are cast to
 Int64 before summing to prevent overflow issues.
 
 See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Expr
 
 Expr


## Examples

```r
pl$DataFrame(list(a=1:4))$select(
pl$col("a")$cummin()$alias("cummin"),
pl$col("a")$cummin(reverse=TRUE)$alias("cummin_reversed")
)
pl$DataFrame(list(a=1:4))$select(
pl$col("a")$cummax()$alias("cummux"),
pl$col("a")$cummax(reverse=TRUE)$alias("cummax_reversed")
)
```


