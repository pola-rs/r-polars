data

# All, is true

## Format

An object of class `character` of length 1.

```r
Expr_all
```

## Returns

Boolean literal

Check if all boolean values in a Boolean column are `TRUE`. This method is an expression - not to be confused with `pl$all` which is a function to select all columns.

## Details

last `all()` in example is this Expr method, the first `pl$all()` refers to "all-columns" and is an expression constructor

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