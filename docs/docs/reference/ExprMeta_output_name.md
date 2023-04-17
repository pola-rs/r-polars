# `ExprMeta_output_name`

Output Name


## Description

Get the column name that this expression would produce.
 It might not always be possible to determine the output name
 as it might depend on the schema of the context. In that case
 this will raise an error.


## Value

R charvec of output names.


## Examples

```r
e = pl$col("alice")$alias("bob")
e$meta$root_names() == "alice"
e$meta$output_name() == "bob"
e$meta$undo_aliases()$meta$output_name() == "alice"
```


