data

# Any (is true)

## Format

An object of class `character` of length 1.

```r
Expr_any
```

## Returns

Boolean literal

Check if any boolean value in a Boolean column is `TRUE`.

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