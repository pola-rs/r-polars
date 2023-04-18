# Div

```r
Expr_div(other)

## S3 method for class 'Expr'
e1 / e2
```

## Arguments

- `other`: literal or Robj which can become a literal
- `e1`: lhs Expr
- `e2`: rhs Expr or anything which can become a literal Expression

## Returns

Exprs

Divide

## Examples

```r
#three syntaxes same result
pl$lit(5) / 10
pl$lit(5) / pl$lit(10)
pl$lit(5)$div(pl$lit(10))
```