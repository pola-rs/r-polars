# Print expr

```r
## S3 method for class 'Expr'
print(x, ...)
```

## Arguments

- `x`: Expr
- `...`: not used

## Returns

self

Print expr

## Examples

```r
pl$col("some_column")$sum()$over("some_other_column")
```