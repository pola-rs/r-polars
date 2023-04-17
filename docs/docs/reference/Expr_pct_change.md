# `Expr_pct_change`

Pct change


## Description

Computes percentage change between values.
 Percentage change (as fraction) between current element and most-recent
 non-null element at least `n` period(s) before the current element.
 Computes the change from the previous row by default.


## Usage

```r
Expr_pct_change(n = 1)
```


## Arguments

Argument      |Description
------------- |----------------
`n`     |     periods to shift for forming percent change.


## Value

Expr


## Examples

```r
df = pl$DataFrame(list( a=c(10L, 11L, 12L, NA_integer_, 12L)))
df$with_column(pl$col("a")$pct_change()$alias("pct_change"))
```


