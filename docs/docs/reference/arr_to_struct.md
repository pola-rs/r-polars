# List to Struct

## Format

function

## Arguments

- `n_field_strategy`: Strategy to determine the number of fields of the struct. default = 'first_non_null' else 'max_width'
- `name_generator`: an R function that takes a scalar column number and outputs a string value. The default NULL is equivalent to the R function `\(idx) paste0("field_",idx)`
- `upper_bound`: upper_bound numeric A polars `LazyFrame` needs to know the schema at all time. The caller therefore must provide an `upper_bound` of struct fields that will be set. If this is incorrectly downstream operation may fail. For instance an `all().sum()` expression will look in the current schema to determine which columns to select. It is adviced to set this value in a lazy query.

## Returns

Expr

List to Struct

## Examples

```r
df = pl$DataFrame(list(a = list(1:3, 1:2)))
df2 = df$select(pl$col("a")$arr$to_struct(
  name_generator =  \(idx) paste0("hello_you_",idx))
  )
df2$unnest()

df2$to_list()
```