data

# Xor

## Format

An object of class `character` of length 1.

```r
Expr_xor(other)
```

## Arguments

- `other`: literal or Robj which can become a literal

## Returns

Expr

combine to boolean expresions with XOR

## Examples

```r
pl$lit(TRUE)$xor(pl$lit(FALSE))
```