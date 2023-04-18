# Expr_map

```r
Expr_map(f, output_type = NULL, agg_list = FALSE)
```

## Arguments

- `f`: a function mapping a series
- `output_type`: NULL or one of pl$dtypes$..., the output datatype, NULL is the same as input.
- `agg_list`: Aggregate list. Map from vector to group in groupby context. Likely not so useful.

## Returns

Expr

Expr_map

## Details

user function return should be a series or any Robj convertable into a Series. In PyPolars likely return must be Series. User functions do fully support `browser()`, helpful to investigate.

## Examples

```r
pl$DataFrame(iris)$select(pl$col("Sepal.Length")$map(\(x) {
  paste("cheese",as.character(x$to_r_vector()))
}, pl$dtypes$Utf8))
```