# `Expr_to_physical`

To physical representation


## Description

expression request underlying physical base representation


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_to_physical
```


## Value

Expr


## Examples

```r
pl$DataFrame(
list(vals = c("a", "x", NA, "a"))
)$with_columns(
pl$col("vals")$cast(pl$Categorical),
pl$col("vals")
$cast(pl$Categorical)
$to_physical()
$alias("vals_physical")
)
```


