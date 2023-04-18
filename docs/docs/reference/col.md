# Start Expression with a column

## Arguments

- `name`:  * a single column by a string
     * all columns by using a wildcard `"*"`
     * multiple columns as vector of strings
     * column by regular expression if the regex starts with `^` and ends with `$`
       
       e.g. pl$DataFrame(iris)$select(pl$col(c("^Sepal.*$")))
     * a single DataType or an R list of DataTypes, select any column of any such DataType
     * Series of utf8 strings abiding to above options

## Returns

Column Exprression

Return an expression representing a column in a DataFrame.

## Examples

```r
df = pl$DataFrame(list(foo=1, bar=2L,foobar="3"))

#a single column by a string
df$select(pl$col("foo"))

#all columns by wildcard
df$select(pl$col("*"))
df$select(pl$all())

#multiple columns as vector of strings
df$select(pl$col(c("foo","bar")))

#column by regular expression if the regex starts with `^` and ends with `$`
df$select(pl$col("^foo.*$"))

#a single DataType
df$select(pl$col(pl$dtypes$Float64))

# ... or an R list of DataTypes, select any column of any such DataType
df$select(pl$col(list(pl$dtypes$Float64, pl$dtypes$Utf8)))

# from Series of names
df$select(pl$col(pl$Series(c("bar","foobar"))))
```