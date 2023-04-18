data

# And

## Format

An object of class `character` of length 1.

```r
Expr_and(other)
```

## Arguments

- `other`: literal or Robj which can become a literal

## Returns

Expr

combine to boolean exprresions with AND

## Examples

```r
pl$lit(TRUE) & TRUE
pl$lit(TRUE)$and(pl$lit(TRUE))
```