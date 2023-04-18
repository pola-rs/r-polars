data

# Or

## Format

An object of class `character` of length 1.

```r
Expr_or(other)
```

## Arguments

- `other`: Expr or into Expr

## Returns

Expr

combine to boolean expresions with OR

## Examples

```r
pl$lit(TRUE) | FALSE
pl$lit(TRUE)$or(pl$lit(TRUE))
```