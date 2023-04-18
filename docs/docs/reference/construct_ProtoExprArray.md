# construct proto Expr array from args

```r
construct_ProtoExprArray(...)
```

## Arguments

- `...`: any Expr or string

## Returns

ProtoExprArray object

construct proto Expr array from args

## Examples

```r
polars:::construct_ProtoExprArray(pl$col("Species"),"Sepal.Width")
```