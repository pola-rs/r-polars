# `Expr_all`

All, is true


## Description

Check if all boolean values in a Boolean column are `TRUE` .
 This method is an expression - not to be confused with
 `pl$all` which is a function to select all columns.


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_all
```


## Details

last `all()` in example is this Expr method, the first `pl$all()` refers
 to "all-columns" and is an expression constructor


## Value

Boolean literal


## Examples

```r
pl$DataFrame(
all=c(TRUE,TRUE),
any=c(TRUE,FALSE),
none=c(FALSE,FALSE)
)$select(
pl$all()$all()
)
```


