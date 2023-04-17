# `Expr_explode`

Explode a list or utf8 Series.


## Description

This means that every item is expanded to a new row.
 
 ( flatten is an alias for explode )


## Format

a method
 
 a method


## Usage

```r
Expr_explode
Expr_flatten
```


## Details

explode/flatten does not support categorical


## Value

Expr


## Examples

```r
pl$DataFrame(list(a=letters))$select(pl$col("a")$explode()$take(0:5))

listed_group_df =  pl$DataFrame(iris[c(1:3,51:53),])$groupby("Species")$agg(pl$all())
print(listed_group_df)
vectors_df = listed_group_df$select(
pl$col(c("Sepal.Width","Sepal.Length"))$explode()
)
print(vectors_df)
```


