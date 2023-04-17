# `construct_ProtoExprArray`

construct proto Expr array from args


## Description

construct proto Expr array from args


## Usage

```r
construct_ProtoExprArray(...)
```


## Arguments

Argument      |Description
------------- |----------------
`...`     |     any Expr or string


## Value

ProtoExprArray object


## Examples

```r
polars:::construct_ProtoExprArray(pl$col("Species"),"Sepal.Width")
```


