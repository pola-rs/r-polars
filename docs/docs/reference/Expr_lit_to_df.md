# `Expr_lit_to_df`

Literal to DataFrame


## Description

collect an expression based on literals into a DataFrame


## Usage

```r
Expr_lit_to_df()
```


## Value

Series


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


