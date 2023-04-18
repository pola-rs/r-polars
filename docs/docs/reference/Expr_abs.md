data

# Abs

## Format

An object of class `character` of length 1.

```r
Expr_abs
```

## Returns

Exprs abs

Compute absolute values

## Examples

```r
pl$DataFrame(list(a=-1:1))$select(pl$col("a"),pl$col("a")$abs()$alias("abs"))
```