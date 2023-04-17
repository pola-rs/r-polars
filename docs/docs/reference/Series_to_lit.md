# `to_lit`

Series to Literal

## Description

convert Series to literal to perform modification and return

## Usage

```r
Series_to_lit()
```

## Value

Expr

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


