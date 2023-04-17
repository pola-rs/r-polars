# `ExprMeta_is_regex_projection`

Is regex projecion.


## Description

Whether this expression expands to columns that match a regex pattern.


## Value

Bool


## Examples

```r
pl$col("^Sepal.*$")$meta$is_regex_projection()
pl$col("Sepal.Length")$meta$is_regex_projection()
```


