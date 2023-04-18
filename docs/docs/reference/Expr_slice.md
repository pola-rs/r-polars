# Get a slice of this expression.

## Format

a method

```r
Expr_slice(offset, length = NULL)
```

## Arguments

- `offset`: numeric or expression, zero-indexed where to start slice negative value indicate starting (one-indexed) from back
- `length`: how many elements should slice contain, default NULL is max length

## Returns

Expr

Get a slice of this expression.

## Examples

```r
#as head
pl$DataFrame(list(a=0:100))$select(
  pl$all()$slice(0,6)
)

#as tail
pl$DataFrame(list(a=0:100))$select(
  pl$all()$slice(-6,6)
)

pl$DataFrame(list(a=0:100))$select(
  pl$all()$slice(80)
)
```