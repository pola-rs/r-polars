# `Expr_any`

Any (is true)


## Description

Check if any boolean value in a Boolean column is `TRUE` .


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_any
```


## Value

Boolean literal


## Examples

```r
pl$DataFrame(
all=c(TRUE,TRUE),
any=c(TRUE,FALSE),
none=c(FALSE,FALSE)
)$select(
pl$all()$any()
)
```


