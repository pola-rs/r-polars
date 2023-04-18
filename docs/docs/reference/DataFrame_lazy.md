data

# New LazyFrame from DataFrame_object$lazy()

## Format

An object of class `character` of length 1.

```r
DataFrame_lazy
```

## Returns

a LazyFrame

Start a new lazy query from a DataFrame

## Examples

```r
pl$DataFrame(iris)$lazy()

#use of lazy method
pl$DataFrame(iris)$lazy()$filter(pl$col("Sepal.Length") >= 7.7)$collect()
```