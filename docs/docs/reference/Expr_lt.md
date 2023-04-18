# Less Than <

```r
Expr_lt(other)

## S3 method for class 'Expr'
e1 < e2
```

## Arguments

- `other`: literal or Robj which can become a literal
- `e1`: lhs Expr
- `e2`: rhs Expr or anything which can become a literal Expression

## Returns

Exprs

lt method and operator

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
#' #three syntaxes same result
pl$lit(5) < 10
pl$lit(5) < pl$lit(10)
pl$lit(5)$lt(pl$lit(10))
```