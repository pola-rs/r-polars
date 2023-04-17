# `Expr_ceil`

Ceiling


## Description

Rounds up to the nearest integer value.
 Only works on floating point Series.


## Format

a method


## Usage

```r
Expr_ceil
```


## Value

Expr


## Examples

```r
pl$DataFrame(list(
a = c(0.33, 0.5, 1.02, 1.5, NaN , NA, Inf, -Inf)
))$select(
pl$col("a")$ceil()
)
```


