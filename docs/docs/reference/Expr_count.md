# `Expr_count`

Count values (len is a alias)


## Description

Count the number of values in this expression.
 Similar to R length()


## Format

An object of class `character` of length 1.
 
 An object of class `character` of length 1.


## Usage

```r
Expr_count
Expr_len
```


## Value

Expr
 
 Expr


## Examples

```r
pl$DataFrame(
all=c(TRUE,TRUE),
any=c(TRUE,FALSE),
none=c(FALSE,FALSE)
)$select(
pl$all()$count()
)
pl$DataFrame(
all=c(TRUE,TRUE),
any=c(TRUE,FALSE),
none=c(FALSE,FALSE)
)$select(
pl$all()$len(),
pl$col("all")$first()$len()$alias("all_first")
)
```


