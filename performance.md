Optimize `polars` performance
================

# Lazy vs eager execution

## Order of operations

In the “Get Started” vignette, we mostly used *eager* execution. This is
the classic type of execution in R: write some code, link functions with
pipes, run the code and it is executed line by line.

Most of the time, this kind of execution is perfectly fine. With
datasets of a reasonable size (let’s say up to a few hundreds of
thousands of observations and a few dozens columns), we don’t really
have to worry about whether our code is optimized to save memory and
time.

However, when we start dealing with much larger datasets, the order in
which functions are applied is extremely important. Indeed, some
functions are much more memory intensive than others.

For instance, let’s say we have a dataset with 1M observations
containing country names and a few numeric columns. We would like to
keep just a few of these countries and sort them alphabetically. Here,
we have two operations: filtering and sorting. Sorting is much harder to
do than filtering. To filter data, we simply check whether each row
fills some conditions, but to sort data we have to compare rows between
them and rearrange them as we go. If we don’t take this into account,
sorting data before filtering it can slow down our pipeline
significantly.

``` r
countries = c("France", "Germany", "United Kingdom", "Japan", "Columbia", 
               "South Korea", "Vietnam", "South Africa", "Senegal", "Iran")

set.seed(123)
test = data.frame(
  country = sample(countries, 1e6, TRUE),
  x = sample(1:100, 1e6, TRUE),
  y = sample(1:1000, 1e6, TRUE)
)

bench::mark(
  sort_filter = {
    tmp = test[order(test$country), ]
    subset(tmp, country %in% c("United Kingdom", "Japan", "Vietnam"))
  },
  filter_sort = {
    tmp = subset(test, country %in% c("United Kingdom", "Japan", "Vietnam"))
    tmp[order(tmp$country), ]
  }
)
```

    ## Warning: Some expressions had a GC in every iteration; so filtering is
    ## disabled.

    ## # A tibble: 2 × 6
    ##   expression       min   median `itr/sec` mem_alloc `gc/sec`
    ##   <bch:expr>  <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
    ## 1 sort_filter   10.75s   10.75s    0.0930    87.2MB    0.372
    ## 2 filter_sort    2.48s    2.48s    0.402     67.1MB    1.21

## How does `polars` help?

We have seen that the order in which functions are applied matters a
lot. But it already takes a long time to deal with large data, we’re not
going to spend even more time trying to optimize our pipeline, right?

This is where *lazy* execution comes into play. The idea is that we
write our code as usual, but this time, we won’t apply it directly on a
dataset but on a lazy dataset, i.e a dataset that is not loaded in
memory yet (in `polars` terms, these are `DataFrame`s and `LazyFrame`s).
Once our code is ready, we call `collect()` at the end of the pipeline.
Before executing our code, `polars` will internally check whether it can
be optimized, for example by reordering some operations.

Let’s re-use the example above but this time with `polars` syntax and
10M observations. It doesn’t make sense to convert a dataset that we
already have in memory to a `LazyFrame` so first we have to export it as
CSV and then we can read it lazily with `lazy_csv_reader()`:

``` r
library(polars)

df_test = csv_reader("data/test.csv")
lf_test = lazy_csv_reader("data/test.csv")
```

Now, we can convert the base R code above to a `polars` query:

``` r
df_test$
  sort(pl$col("country"))$
  filter(
    pl$col("country")$is_in(pl$lit(c("United Kingdom", "Japan", "Vietnam")))
  )
```

    ## shape: (3000835, 3)
    ## ┌─────────┬─────┬─────┐
    ## │ country ┆ x   ┆ y   │
    ## │ ---     ┆ --- ┆ --- │
    ## │ str     ┆ i64 ┆ i64 │
    ## ╞═════════╪═════╪═════╡
    ## │ Japan   ┆ 97  ┆ 7   │
    ## │ Japan   ┆ 96  ┆ 672 │
    ## │ Japan   ┆ 17  ┆ 710 │
    ## │ Japan   ┆ 68  ┆ 41  │
    ## │ ...     ┆ ... ┆ ... │
    ## │ Vietnam ┆ 62  ┆ 8   │
    ## │ Vietnam ┆ 52  ┆ 988 │
    ## │ Vietnam ┆ 85  ┆ 982 │
    ## │ Vietnam ┆ 74  ┆ 692 │
    ## └─────────┴─────┴─────┘

This works for the `DataFrame`, that uses eager execution. For the
`LazyFrame`, we can write the same query:

``` r
lazy_query = lf_test$
  sort(pl$col("country"))$
  filter(
    pl$col("country")$is_in(pl$lit(c("United Kingdom", "Japan", "Vietnam")))
  )

lazy_query
```

    ## [1] "polars LazyFrame naive plan: (run ldf$describe_optimized_plan() to see the optimized plan)"
    ##   FILTER col("country").is_in([Series]) FROM
    ##     SORT BY [col("country")]
    ##       CSV SCAN data/test.csv
    ##       PROJECT */3 COLUMNS

However, this doesn’t do anything to the data until we call `collect()`
at the end. We can now compare the two approaches:

``` r
bench::mark(
  eager = df_test$
    sort(pl$col("country"))$
    filter(
      pl$col("country")$is_in(pl$lit(c("United Kingdom", "Japan", "Vietnam")))
    ),
  lazy = lazy_query$collect(),
  iterations = 10
)
```

    ## # A tibble: 2 × 6
    ##   expression      min   median `itr/sec` mem_alloc `gc/sec`
    ##   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
    ## 1 eager         1.13s    1.18s     0.839    7.94KB        0
    ## 2 lazy       524.08ms  557.8ms     1.78       640B        0

On this very simple query, using lazy execution instead of eager
execution lead to a 1.7-2.2x decrease in time.

So what happened? Under the hood, `polars` reorganized the query so that
it filters the data first, and then sorts the remaining data. This can
be seen by comparing the original query (`describe_plan()`) and the
optimized query (`describe_optimized_plan()`):

``` r
lazy_query$describe_plan()
```

    ##   FILTER col("country").is_in([Series]) FROM
    ##     SORT BY [col("country")]
    ##       CSV SCAN data/test.csv
    ##       PROJECT */3 COLUMNS

``` r
lazy_query$describe_optimized_plan()
```

    ##   SORT BY [col("country")]
    ##     CSV SCAN data/test.csv
    ##     PROJECT */3 COLUMNS
    ##     SELECTION: col("country").is_in([Series])

Note that the queries must be read from bottom to top, i.e the optimized
query is “select the dataset where the column ‘country’ matches these
values, then sort the data by the values of ‘country’”.

# Use `polars` functions

`polars` comes with a large number of built-in, optimized, basic
functions that should cover most aspects of data wrangling. These
functions are designed to be very memory efficient. Therefore, using R
functions or converting data back and forth between `polars` and R is
discouraged as it can lead to a large decrease in efficiency.

Let’s use the test data from the previous section and let’s say that we
only want to check whether each country contains “na”. This can be done
in (at least) two ways: with the built-in function `contains()` and with
the base R function `grepl()`. However, using the built-in function is
much faster:

``` r
bench::mark(
  contains = df_test$with_columns(
    pl$col("country")$str$contains("na")
  ),
  grepl = df_test$with_column(
    pl$col("country")$map(\(s) { # map with a R function
      grepl("na", s)
    })
  ),
  iterations = 10
)
```

    ## # A tibble: 2 × 6
    ##   expression      min   median `itr/sec` mem_alloc `gc/sec`
    ##   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
    ## 1 contains   344.01ms 377.98ms     2.63      447KB     0   
    ## 2 grepl         2.04s    2.07s     0.479     115MB     1.60

Using custom R functions can be useful, but when possible, you should
use the functions provided by `polars`. See the Reference tab for a
complete list of functions.

# Streaming data

How?
