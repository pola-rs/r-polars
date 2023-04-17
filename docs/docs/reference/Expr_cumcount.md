# `Expr_cumcount`

Cumulative count


## Description

Get an array with the cumulative count computed at every element.
 Counting from 0 to len


## Format

a method


## Usage

```r
Expr_cumcount(reverse = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
`reverse`     |     bool, default FALSE, if true roll over vector from back to forth


## Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to
 Int64 before summing to prevent overflow issues.
 
 cumcount does not seem to count within lists.


## Value

Expr


## Examples

```r
pl$DataFrame(list(a=1:4))$select(
pl$col("a")$cumcount()$alias("cumcount"),
pl$col("a")$cumcount(reverse=TRUE)$alias("cumcount_reversed")
)
```


