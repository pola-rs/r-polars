# `arr_eval`

eval sublists (kinda like lapply)


## Description

Run any polars expression against the lists' elements.


## Format

function


## Arguments

Argument      |Description
------------- |----------------
`Expr`     |     Expression to run. Note that you can select an element with `pl$first()` , or `pl$col()`
`parallel`     |     bool Run all expression parallel. Don't activate this blindly. Parallelism is worth it if there is enough work to do per thread. This likely should not be use in the groupby context, because we already parallel execution per group


## Value

Expr


## Examples

```r
df = pl$DataFrame(a = list(c(1,8,3), b = c(4,5,2)))
df$select(pl$all()$cast(pl$dtypes$Int64))$with_column(
pl$concat_list(c("a","b"))$arr$eval(pl$element()$rank())$alias("rank")
)
```


