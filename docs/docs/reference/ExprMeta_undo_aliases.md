# Undo aliases

## Returns

Expr with aliases undone

Undo any renaming operation like `alias` or `keep_name`.

## Examples

```r
e = pl$col("alice")$alias("bob")
e$meta$root_names() == "alice"
e$meta$output_name() == "bob"
e$meta$undo_aliases()$meta$output_name() == "alice"
```