data

# Rename Expr output

## Format

An object of class `character` of length 1.

```r
Expr_alias(name)
```

## Arguments

- `name`: string new name of output

## Returns

Expr

Rename the output of an expression.

## Examples

```r
pl$col("bob")$alias("alice")
```