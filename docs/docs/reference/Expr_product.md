# `Expr_product`

Product


## Description

Compute the product of an expression.


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_product
```


## Details

does not support integer32 currently, .cast() to f64 or i64 first.


## Value

Expr


## Examples

```r
pl$DataFrame(list(x=c(1,2,3)))$select(pl$col("x")$product()==6) #is true
```


