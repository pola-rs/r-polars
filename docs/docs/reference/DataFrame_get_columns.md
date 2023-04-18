data

# Get columns (as Series)

## Format

An object of class `character` of length 1.

```r
DataFrame_get_columns
```

## Returns

list of series

get columns as list of series

## Examples

```r
df = pl$DataFrame(iris[1,])
df$get_columns()
```