# Not Equal !=

```r
Expr_neq(other)

## S3 method for class 'Expr'
e1 != e2
```

## Arguments

- `other`: literal or Robj which can become a literal
- `e1`: lhs Expr
- `e2`: rhs Expr or anything which can become a literal Expression

## Returns

Exprs

neq method and operator

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
#' #three syntaxes same result
pl$lit(1) != 2
pl$lit(1) !=  pl$lit(2)
pl$lit(1)$neq(pl$lit(2))
```