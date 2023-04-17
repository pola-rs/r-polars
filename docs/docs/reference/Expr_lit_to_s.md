# `Expr_lit_to_s`

Literal to Series


## Description

collect an expression based on literals into a Series


## Usage

```r
Expr_lit_to_s()
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
$lit_to_s()
)
```


