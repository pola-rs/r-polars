data

# Not !

## Format

An object of class `character` of length 1.

```r
Expr_is_not(other)

## S3 method for class 'Expr'
!x
```

## Arguments

- `x`: Expr
- `other`: literal or Robj which can become a literal

## Returns

Exprs

not method and operator

## Examples

```r
#two syntaxes same result
pl$lit(TRUE)$is_not()
!pl$lit(TRUE)
```