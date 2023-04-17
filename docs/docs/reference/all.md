# `all`

New Expr referring to all columns


## Description

Not to mix up with `Expr_object$all()` which is a 'reduce Boolean columns by AND' method.


## Details

last `all()` in example is this Expr method, the first `pl$all()` refers
 to "all-columns" and is an expression constructor


## Value

Boolean literal


## Examples

```r
pl$DataFrame(list(all=c(TRUE,TRUE),some=c(TRUE,FALSE)))$select(pl$all()$all())
```


