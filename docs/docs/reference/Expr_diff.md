# `Expr_diff`

Diff


## Description

Calculate the n-th discrete difference.


## Usage

```r
Expr_diff(n = 1, null_behavior = "ignore")
```


## Arguments

Argument      |Description
------------- |----------------
`n`     |     Integerish Number of slots to shift.
`null_behavior`     |     option default 'ignore', else 'drop'


## Value

Expr


## Examples

```r
pl$DataFrame(list( a=c(20L,10L,30L,40L)))$select(
pl$col("a")$diff()$alias("diff_default"),
pl$col("a")$diff(2,"ignore")$alias("diff_2_ignore")
)
```


