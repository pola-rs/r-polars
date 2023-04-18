# Pop

## Returns

R list of Expr(s) usually one, only multiple if top Expr took more Expr as input.

Pop the latest expression and return the input(s) of the popped expression.

## Examples

```r
e1 = pl$lit(40) + 2
e2 = pl$lit(42)$sum()

e1
e1$meta$pop()

e2
e2$meta$pop()
```