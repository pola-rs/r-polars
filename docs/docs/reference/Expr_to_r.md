# to_r: for debuging an expression

## Format

Method

```r
Expr_to_r(df = NULL, i = 0)
```

## Arguments

- `df`: otherwise a DataFrame to evaluate in, default NULL is an empty DataFrame
- `i`: numeric column to extract zero index default first, expression could generate multiple columns

## Returns

R object

debug an expression by evaluating in empty DataFrame and return first series to R

## Examples

```r
pl$lit(1:3)$to_r()
pl$expr_to_r(pl$lit(1:3))
pl$expr_to_r(1:3)
```