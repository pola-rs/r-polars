data

# Index of First Unique Value.

## Format

An object of class `character` of length 1.

```r
Expr_arg_unique
```

## Returns

Expr

Index of First Unique Value.

## Examples

```r
pl$select(pl$lit(c(1:2,1:3))$arg_unique())
```