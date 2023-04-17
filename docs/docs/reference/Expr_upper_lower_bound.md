# `Expr_upper_lower_bound`

Upper bound


## Description

Calculate the upper/lower bound.
 Returns a unit Series with the highest value possible for the dtype of this
 expression.


## Format

Method
 
 Method


## Usage

```r
Expr_upper_bound
Expr_lower_bound
```


## Details

Notice lower bound i32 exported to R is NA_integer_ for now


## Value

Expr


## Examples

```r
pl$DataFrame(i32=1L,f64=1)$select(pl$all()$upper_bound())
pl$DataFrame(i32=1L,f64=1)$select(pl$all()$lower_bound())
```


