# DataFrame dtypes

```r
DataFrame_dtypes()

DataFrame_schema()
```

## Returns

width as numeric scalar

width as numeric scalar

Get dtypes of columns in DataFrame. Dtypes can also be found in column headers when printing the DataFrame.

Get dtypes of columns in DataFrame. Dtypes can also be found in column headers when printing the DataFrame.

## Examples

```r
pl$DataFrame(iris)$dtypes

pl$DataFrame(iris)$schema
```