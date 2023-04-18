# Interpolate `Nulls`

```r
Expr_interpolate(method = "linear")
```

## Arguments

- `method`: string 'linear' or 'nearest', default "linear"

## Returns

Expr

Fill nulls with linear interpolation over missing values. Can also be used to regrid data to a new grid - see examples below.

## Examples

```r
pl$select(pl$lit(c(1,NA,4,NA,100,NaN,150))$interpolate())

#x, y interpolation over a grid
df_original_grid = pl$DataFrame(list(
  grid_points = c(1, 3, 10),
  values = c(2.0, 6.0, 20.0)
))
df_new_grid = pl$DataFrame(list(grid_points = (1:10)*1.0))

# Interpolate from this to the new grid
df_new_grid$join(
  df_original_grid, on="grid_points", how="left"
)$with_columns(pl$col("values")$interpolate())
```