minipolars\_teaser
================
Søren Welling
7/22/2022

## What is minipolars

Minipolars is an unofficial porting of polars (pola-rs) in to an R
package. I aim to finish the project in 2022. Beta should be ready by
the end of September 2022.

[Polars](http://pola.rs) is the
[fastest](https://h2oai.github.io/db-benchmark/) data table query
library. The syntax is related to Spark, but column oriented and not row
oriented. All R libraries are also column oriented so this should feel
familiar. Unlike Spark, polars is natively multithreaded instead of
multinode(d). This make polars simple to install and use as any other R
package. Like Spark and SQL-variants polars optimizes queries for memory
consuption and speed so you don’t have to. Expect 5-10 speedup compared
to dplyr on simple transformations from &gt;500Mb data. When chaining
many operations the speedup due to optimization can be even higher.
Polars is built on the apache-arrow memory model.

This port relies on extendr <https://github.com/extendr> which is the R
equivalent to pyo3+maturin. Extendr is very convenient for calling rust
from R and the reverse.

## Hello world

``` r
#loading the package minipolars only exposes a few functions 
library(minipolars)

#all constructors are accessed via pl

#Here we go, Hello world written with polars expressions
pl$col("hello")$sum()$over(c("world","from"))$alias("polars")
```

    ## polars Expr: col("hello").sum().over([col("world"), col("from")]).alias("polars")

## Typical ussage

Where `dplyr` has `%>%`-piping and \``data.table` has `[,]`-indexing,
method chaining `object$m1()$m2()` is the bread and butter syntax of
polars. For now the best learning material to understand the syntax and
the power of polars is the [official user guide for
python](https://pola-rs.github.io/polars-book/user-guide/). As
minipolars syntax is the same ( except `$` instead of `.`) the guide
should be quite useful. The following example shows a typical
‘polar\_frame’ method together with chained expressions.

``` r
#create polar_frames from iris
df = pl$DataFrame(iris)

#make selection (similar to dplyr mutute() and data.table [,.()] ) and use expressions or strings.

df = df$select(
  pl$col("Sepal.Width")$sum()$over("Species")$alias("sw_sum_over_species"),
  pl$col("Sepal.Length")$sum()$over("Species")$alias("sl_sum_over_species"),
  "Petal.Width"
)

#polars expressions are column instructions

#1 take the column named Sepal.Width
#2 sum it...
#3 over(by) the column  Species
#4 rename/alias to sw_sum_over_species


#convert back to data.frame
head(df$as_data_frame())
```

    ##   sw_sum_over_species sl_sum_over_species Petal.Width
    ## 1               171.4               250.3         0.2
    ## 2               171.4               250.3         0.2
    ## 3               171.4               250.3         0.2
    ## 4               171.4               250.3         0.2
    ## 5               171.4               250.3         0.2
    ## 6               171.4               250.3         0.4

## `polar_frame` from `series` and R vectors

``` r
#a single column outside a polars_frame is called a series
pl$Series((1:5) * 5,"my_series")
```

    ## polars Series: shape: (5,)
    ## Series: 'my_series' [f64]
    ## [
    ##  5.0
    ##  10.0
    ##  15.0
    ##  20.0
    ##  25.0
    ## ]

``` r
#Create polar_From  from a list of series and/or plain R vectors.
values = list (
  newname = pl$Series(c(1,2,3,4,5),name = "b"), #overwrite name b with 'newname'
  pl$Series((1:5) * 5,"a"),
  pl$Series(letters[1:5],"b"),
  c(5,4,3,2,1), #unnamed vector
  named_vector = c(15,14,13,12,11) ,#named provide
  c(5,4,3,2,0)
)

pl$DataFrame(values)
```

    ## polars DataFrame: shape: (5, 6)
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

# Data types

``` r
#polars is strongly typed. Data-types can be created like this:
pl$dtypes$Float64
```

    ## polars DataType: Float64

``` r
pl$dtypes$Int32
```

    ## polars DataType: Int32

``` r
pl$dtypes$Int64 #not R native type
```

    ## polars DataType: Int64

# Read csv and the `polars_lazy_frame`

``` r
  #using iris.csv as example
  write.csv(iris, "iris.csv",row.names = FALSE)

  #read csv into a lazy_polar_frame and compute sum of Sepal.Width over Species
  lpf = pl$lazy_csv_reader("iris.csv")$select(
    pl$col("Sepal.Width")$sum()$over("Species")
  )
  
  #a lazy frame is only a tree of instructions
  print(lpf) #same as lpf$describe_plan()
```

    ## [1] "polars LazyFrame naive plan: (run ldf$describe_optimized_plan() to see the optimized plan)"
    ## SELECT 1 COLUMNS: [col("Sepal.Width").sum().over([col("Species")])]
    ## FROM
    ## CSV SCAN iris.csv; PROJECT */5 COLUMNS; SELECTION: None

``` r
  #read plan from bottom to top, says:  "read entire csv, then compute sum x over y"
  
  #what polars actually will do is the optimized plan
  
  lpf$describe_optimized_plan()
```

    ## SELECT 1 COLUMNS: [col("Sepal.Width").sum().over([col("Species")])]
    ## FROM
    ## CSV SCAN iris.csv; PROJECT 2/5 COLUMNS; SELECTION: None

    ## NULL

``` r
  #optimized plan says:  "read only column x and y from csv, compute sum x over y"
  
  #Only reading some columns or in other cases some row in to memory can save speed downstream operations. This is called peojection. 
  
  
  #to execute plan, simply call $collect() and get a polars_frame as result
  
  lpf$collect()
```

    ## polars DataFrame: shape: (150, 1)
    ## ┌─────────────┐
    ## │ Sepal.Width │
    ## │ ---         │
    ## │ f64         │
    ## ╞═════════════╡
    ## │ 171.4       │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 171.4       │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 171.4       │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 171.4       │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ ...         │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 148.7       │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 148.7       │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 148.7       │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 148.7       │
    ## └─────────────┘

## User pass user defined functions to polars

It is possible to mix R code with polars by passing user defined
functions to polars. User defined functions are slower. Use native polar
functions/expressions where possible.

``` r
    pl$DataFrame(iris)$select(
      pl$col("Sepal.Length")$map(\(s) {
        x = s$to_r_vector() #convert from Series to a native R vector
        x[x>=5] = 10
        x[1:10] # if return is R vector, it will automatically be converted to Series again
      })
    )$as_data_frame()
```

    ##    Sepal.Length
    ## 1          10.0
    ## 2           4.9
    ## 3           4.7
    ## 4           4.6
    ## 5          10.0
    ## 6          10.0
    ## 7           4.6
    ## 8          10.0
    ## 9           4.4
    ## 10          4.9
