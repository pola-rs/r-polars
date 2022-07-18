# minipolars
Use awesome polars dataframe library from R!

# build
build package with `rextender::document()` or `R CMD INSTALL --no-multiarch --with-keep.source minipolars`
rust nightly toolchain required.

#example
see example in "./test/rough_test.R"


minipolars\_teaser
================
Søren Welling
7/18/2022

## minipolar

This document demonstrates the feasibility of wrapping the excellent
data table library polars <http://pola.rs> in an R package. Spoiler: It
is quite possible.

Besides polars, this wrapping relies on extendr
<https://github.com/extendr> which is the R equivalent to pyo3+maturin.

``` r
#loading polars as regular r package would all functions exposed would give a huge name space collision with sum(), col() from base R.
library(minipolars) #corrosponds import any public function, similar to `use minipolars::*` 


#instead I suggest to use an isolated namespace 
minipolars::import_polars_as_()



#the biggest change is to use $-operator for method call instead of .
pl::col("hello")$sum()$over(c("world","from"))$alias("polars")
```

    ## polars_expr: col("hello").sum().over([col("world"), col("from")]).alias("polars")

## chain ‘polar\_frame’ methods together with chained expressions

``` r
#creating polar_frame  iris, perform selection and convert back to data.frame
pf = pl::pf(iris)

#make selection with expressions or strings, convert back to data.frame
pf$select(
  pl::col("Sepal.Width")$sum()$over("Species")$alias("sw_sum_over_species"),
  pl::col("Sepal.Length")$sum()$over("Species")$alias("sl_sum_over_species"),
  "Petal.Width"
)$as_data_frame() %>% head
```

    ##   sw_sum_over_species sl_sum_over_species Petal.Width
    ## 1               171.4               250.3         0.2
    ## 2               171.4               250.3         0.2
    ## 3               171.4               250.3         0.2
    ## 4               171.4               250.3         0.2
    ## 5               171.4               250.3         0.2
    ## 6               171.4               250.3         0.4

## create ‘polar\_frame’ from mix of series and vectors

``` r
#creating polar_frame from mixed columns
values = list (
  newname = pl::series(c(1,2,3,4,5),name = "b"), #overwrite name b with newname
  pl::series((1:5) * 5,"a"),
  pl::series(letters[1:5],"b"),
  c(5,4,3,2,1), #unnamed vector
  named_vector = c(15,14,13,12,11) ,#named provide
  c(5,4,3,2,0)
)

pl::pf(values)
```

    ## shape: (5, 6)
    ## ┌─────────┬──────┬─────┬─────────────┬──────────────┬─────────────┐
    ## │ newname ┆ a    ┆ b   ┆ newcolumn_1 ┆ named_vector ┆ newcolumn_2 │
    ## │ ---     ┆ ---  ┆ --- ┆ ---         ┆ ---          ┆ ---         │
    ## │ f64     ┆ f64  ┆ str ┆ f64         ┆ f64          ┆ f64         │
    ## ╞═════════╪══════╪═════╪═════════════╪══════════════╪═════════════╡
    ## │ 1.0     ┆ 5.0  ┆ a   ┆ 5.0         ┆ 15.0         ┆ 5.0         │
    ## ├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 2.0     ┆ 10.0 ┆ b   ┆ 4.0         ┆ 14.0         ┆ 4.0         │
    ## ├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 3.0     ┆ 15.0 ┆ c   ┆ 3.0         ┆ 13.0         ┆ 3.0         │
    ## ├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 4.0     ┆ 20.0 ┆ d   ┆ 2.0         ┆ 12.0         ┆ 2.0         │
    ## ├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 5.0     ┆ 25.0 ┆ e   ┆ 1.0         ┆ 11.0         ┆ 0.0         │
    ## └─────────┴──────┴─────┴─────────────┴──────────────┴─────────────┘

``` r
#datatypes
pl::datatype("Float64")
```

    ## polars_datatype: Float64

``` r
pl::datatype("integer")
```

    ## polars_datatype: Int32
