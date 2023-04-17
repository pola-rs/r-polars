# `Expr_mode`

Mode


## Description

Compute the most occurring value(s). Can return multiple Values.


## Format

a method


## Usage

```r
Expr_mode
```


## Value

Expr


## Examples

```r
df =pl$DataFrame(list(a=1:6,b = c(1L,1L,3L,3L,5L,6L), c = c(1L,1L,2L,2L,3L,3L)))
df$select(pl$col("a")$mode())
df$select(pl$col("b")$mode())
df$select(pl$col("c")$mode())
```


