# Take every n'th element

## Format

a method

```r
Expr_take_every(n)
```

## Arguments

- `n`: positive integerish value

## Returns

Expr

Take every nth value in the Series and return as a new Series.

## Examples

```r
pl$DataFrame(list(a=0:24))$select(pl$col("a")$take_every(6))
```