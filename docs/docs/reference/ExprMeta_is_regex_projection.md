# Is regex projecion.

## Returns

Bool

Whether this expression expands to columns that match a regex pattern.

## Examples

```r
pl$col("^Sepal.*$")$meta$is_regex_projection()
pl$col("Sepal.Length")$meta$is_regex_projection()
```