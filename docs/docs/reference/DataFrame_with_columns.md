# `with_columns`

modify/append column(s)

## Description

add or modify columns with expressions

## Usage

```r
DataFrame_with_columns(...)
DataFrame_with_column(expr)
```

## Arguments

| Argument | Description                                                      | 
| -------- | ---------------------------------------------------------------- |
| `...`         | any expressions or string column name, or same wrapped in a list | 
| `expr`         | a single expression or string                                    | 

## Details

Like dplyr `mutate()` as it keeps unmentioned columns unlike $select().

with\_column is derived from with\_columns but takes only one expression argument

## Value

DataFrame

DataFrame

## Examples

```r
pl$DataFrame(iris)$with_columns(
pl$col("Sepal.Length")$abs()$alias("abs_SL"),
(pl$col("Sepal.Length")+2)$alias("add_2_SL")
)

#rename columns by naming expression is concidered experimental
pl$set_polars_options(named_exprs = TRUE) #unlock
pl$DataFrame(iris)$with_columns(
pl$col("Sepal.Length")$abs(), #not named expr will keep name "Sepal.Length"
SW_add_2 = (pl$col("Sepal.Width")+2)
)
```


