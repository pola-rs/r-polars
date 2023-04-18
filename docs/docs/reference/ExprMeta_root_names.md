# Root Name

## Returns

R charvec of root names.

Get a vector with the root column name

## Examples

```r
e = pl$col("alice")$alias("bob")
e$meta$root_names() == "alice"
e$meta$output_name() == "bob"
e$meta$undo_aliases()$meta$output_name() == "alice"
```