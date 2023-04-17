# `Expr_filter`

Filter a single column.


## Description

Mostly useful in an aggregation context. If you want to filter on a DataFrame
 level, use `LazyFrame.filter` .
 
 where() is an alias for pl$filter


## Format

a method


## Usage

```r
Expr_filter(predicate)
Expr_where(predicate)
```


## Arguments

Argument      |Description
------------- |----------------
`predicate`     |     Expr or something Into<Expr> . Should be a boolean expression.


## Value

Expr


## Examples

```r
df = pl$DataFrame(list(
group_col =  c("g1", "g1", "g2"),
b = c(1, 2, 3)
))

df$groupby("group_col")$agg(
pl$col("b")$filter(pl$col("b") < 2)$sum()$alias("lt"),
pl$col("b")$filter(pl$col("b") >= 2)$sum()$alias("gte")
)
```


