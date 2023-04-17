# `Expr_n_unique`

Count number of unique values


## Description

Count number of unique values.
 Similar to R length(unique(x))


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_n_unique
```


## Value

Expr


## Examples

```r
pl$DataFrame(iris)$select(pl$col("Species")$n_unique())
```


