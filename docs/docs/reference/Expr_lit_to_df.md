# Literal to DataFrame

```r
Expr_lit_to_df()
```

## Returns

Series

collect an expression based on literals into a DataFrame

## Examples

```r
(
  pl$Series(list(1:1, 1:2, 1:3, 1:4))
  $print()
  $to_lit()
    $arr$lengths()
    $sum()
    $cast(pl$dtypes$Int8)
  $lit_to_df()
)
```