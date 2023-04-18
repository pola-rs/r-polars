data

# Count number of unique values

## Format

An object of class `character` of length 1.

```r
Expr_n_unique
```

## Returns

Expr

Count number of unique values. Similar to R length(unique(x))

## Examples

```r
pl$DataFrame(iris)$select(pl$col("Species")$n_unique())
```