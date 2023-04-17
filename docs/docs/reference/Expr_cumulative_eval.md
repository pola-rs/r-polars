# `Expr_cumulative_eval`

Cumulative eval


## Description

Run an expression over a sliding window that increases `1` slot every iteration.


## Usage

```r
Expr_cumulative_eval(expr, min_periods = 1L, parallel = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
`expr`     |     Expression to evaluate
`min_periods`     |     Number of valid values there should be in the window before the expression is evaluated. valid values = `length - null_count`
`parallel`     |     Run in parallel. Don't do this in a groupby or another operation that already has much parallelization.


## Details

Warnings
 
 This functionality is experimental and may change without it being considered a
 breaking change.
 This can be really slow as it can have `O(n^2)` complexity. Don't use this
 for operations that visit all elements.


## Value

Expr


## Examples

```r
pl$lit(1:5)$cumulative_eval(pl$element()$first()-pl$element()$last() ** 2)$to_r()
```


