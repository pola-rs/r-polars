data

# Apply filter to LazyFrame

## Format

An object of class `character` of length 1.

```r
LazyFrame_filter(expr)
```

## Arguments

- `expr`: one Expr or string naming a column

## Returns

A new `LazyFrame` object with add/modified column.

Filter rows with an Expression definining a boolean column

## Examples

```r
pl$DataFrame(iris)$lazy()$filter(pl$col("Species")=="setosa")$collect()
```