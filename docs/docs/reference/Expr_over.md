# `Expr_over`

over


## Description

Apply window function over a subgroup.
 This is similar to a groupby + aggregation + self join.
 Or similar to window functions in Postgres <https://www.postgresql.org/docs/current/tutorial-window.html> _.


## Usage

```r
Expr_over(...)
```


## Arguments

Argument      |Description
------------- |----------------
`...`     |     of strings or columns to group by


## Value

Expr


## Examples

```r
pl$DataFrame(
val = 1:5,
a = c("+","+","-","-","+"),
b = c("+","-","+","-","+")
)$select(
pl$col("val")$count()$over("a","b")
)
```


