# `ExprCat_set_ordering`

Set Ordering


## Description

Determine how this categorical series should be sorted.


## Arguments

Argument      |Description
------------- |----------------
`ordering`     |     string either 'physical' or 'lexical'  

*  'physical' -> Use the physical representation of the categories to determine the order (default). 

*  'lexical' -> Use the string values to determine the ordering.


## Value

bool: TRUE if equal


## Examples

```r
df = pl$DataFrame(
cats =  c("z", "z", "k", "a", "b"),
vals =  c(3, 1, 2, 2, 3)
)$with_columns(
pl$col("cats")$cast(pl$Categorical)$cat$set_ordering("physical")
)
df$select(pl$all()$sort())
```


