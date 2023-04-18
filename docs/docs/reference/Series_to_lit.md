# Series to Literal

```r
Series_to_lit()
```

## Returns

Expr

convert Series to literal to perform modification and return

## Examples

```r
(
  pl$Series(list(1:1, 1:2, 1:3, 1:4))
  $print()
  $to_lit()
    $arr$lengths()
    $sum()
    $cast(pl$dtypes$Int8)
  $lit_to_s()
)
```