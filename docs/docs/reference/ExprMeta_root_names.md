# `ExprMeta_root_names`

Root Name


## Description

Get a vector with the root column name


## Value

R charvec of root names.


## Examples

```r
e = pl$col("alice")$alias("bob")
e$meta$root_names() == "alice"
e$meta$output_name() == "bob"
e$meta$undo_aliases()$meta$output_name() == "alice"
```


