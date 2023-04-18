# Get Column (as one Series)

```r
DataFrame_get_column(name)
```

## Arguments

- `name`: name of column to extract as Series

## Returns

Series

get one column by name as series

## Examples

```r
df = pl$DataFrame(iris[1,])
df$get_column("Species")
```