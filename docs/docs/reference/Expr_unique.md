# `Expr_unique`

get unqie values


## Description

Get unique values of this expression.
 Similar to R unique()


## Usage

```r
Expr_unique(maintain_order = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
`maintain_order`     |     bool, if TRUE guranteed same order, if FALSE maybe


## Value

Expr


## Examples

```r
pl$DataFrame(iris)$select(pl$col("Species")$unique())
```


