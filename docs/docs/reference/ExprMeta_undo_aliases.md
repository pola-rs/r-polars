# `ExprMeta_undo_aliases`

Undo aliases


## Description

Undo any renaming operation like `alias` or `keep_name` .


## Value

Expr with aliases undone


## Examples

```r
e = pl$col("alice")$alias("bob")
e$meta$root_names() == "alice"
e$meta$output_name() == "bob"
e$meta$undo_aliases()$meta$output_name() == "alice"
```


