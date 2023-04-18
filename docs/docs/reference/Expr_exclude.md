# Exclude certain columns from a wildcard/regex selection.

```r
Expr_exclude(columns)
```

## Arguments

- `columns`: given param type:
    
     * string: exclude name of column or exclude regex starting with ^and ending with$
     * character vector: exclude all these column names, no regex allowed
     * DataType: Exclude any of this DataType
     * List(DataType): Excldue any of these DataType(s)

## Returns

Expr

You may also use regexes in the exclude list. They must start with `^` and end with `$`.

## Examples

```r
#make DataFrame
 df = pl$DataFrame(iris)

 #by name(s)
 df$select(pl$all()$exclude("Species"))

 #by type
 df$select(pl$all()$exclude(pl$Categorical))
 df$select(pl$all()$exclude(list(pl$Categorical,pl$Float64)))

 #by regex
 df$select(pl$all()$exclude("^Sepal.*$"))
```