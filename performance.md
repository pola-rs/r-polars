Optimize `polars` performance
================

As highlighted by the [DuckDB
benchmarks](https://duckdblabs.github.io/db-benchmark/), `polars` is
very efficient to deal with large datasets. Still, one can make `polars`
even faster by following some good practices.

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
    ## 1 sort_filter   10.71s   10.71s    0.0934    87.2MB    0.280
    ## 2 filter_sort    2.73s    2.73s    0.367     67.1MB    1.10

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
10M observations. For the purpose of this vignette, we can create a
`LazyFrame` directly in our session, but if the data was stored in a CSV
file for instance, we would have to scan it first with `pl$scan_csv()`:

``` r
library(polars)

set.seed(123)
df_test = pl$DataFrame(
  country = sample(countries, 1e7, TRUE),
  x = sample(1:100, 1e7, TRUE),
  y = sample(1:1000, 1e7, TRUE)
)

lf_test = df_test$lazy()
```

Now, we can convert the base R code above to a `polars` query:

``` r
df_test$
  sort(pl$col("country"))$
  filter(
    pl$col("country")$is_in(pl$lit(c("United Kingdom", "Japan", "Vietnam")))
  )
```

    ## shape: (3_000_835, 3)
    ## ┌─────────┬─────┬─────┐
    ## │ country ┆ x   ┆ y   │
    ## │ ---     ┆ --- ┆ --- │
    ## │ str     ┆ i32 ┆ i32 │
    ## ╞═════════╪═════╪═════╡
    ## │ Japan   ┆ 97  ┆ 7   │
    ## │ Japan   ┆ 96  ┆ 672 │
    ## │ Japan   ┆ 17  ┆ 710 │
    ## │ Japan   ┆ 68  ┆ 41  │
    ## │ …       ┆ …   ┆ …   │
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
    ## FILTER col("country").is_in([Series]) FROMSORT BY [col("country")]
    ##   DF ["country", "x", "y"]; PROJECT */3 COLUMNS; SELECTION: "None"

However, this doesn’t do anything to the data until we call `collect()`
at the end. We can now compare the two approaches (in the `lazy` timing,
calling `collect()` both reads the data and process it, so we include
the data loading part in the `eager` timing as well):

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
    ## 1 eager         1.22s    1.51s     0.659    9.14KB        0
    ## 2 lazy       648.55ms  966.6ms     0.942      848B        0

On this very simple query, using lazy execution instead of eager
execution lead to a 1.7-2.2x decrease in time.

So what happened? Under the hood, `polars` reorganized the query so that
it filters rows while reading the csv into memory, and then sorts the
remaining data. This can be seen by comparing the original query
(`describe_plan()`) and the optimized query
(`describe_optimized_plan()`):

``` r
lazy_query$describe_plan()
```

    ## FILTER col("country").is_in([Series]) FROMSORT BY [col("country")]
    ##   DF ["country", "x", "y"]; PROJECT */3 COLUMNS; SELECTION: "None"

``` r
lazy_query$describe_optimized_plan()
```

    ## SORT BY [col("country")]
    ##   DF ["country", "x", "y"]; PROJECT */3 COLUMNS; SELECTION: "col(\"country\").is_in([Series])"

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
  grepl = df_test$with_columns(
    pl$col("country")$map(\(s) { # map with a R function
      grepl("na", s)
    })
  ),
  grepl_nv = df_test$limit(1e6)$with_columns( 
    pl$col("country")$apply(\(str) {
      grepl("na", str)
    }, return_type = pl$Boolean)
  ),
  iterations = 10
)
```

    ## Warning: Some expressions had a GC in every iteration; so filtering is
    ## disabled.

    ## # A tibble: 3 × 6
    ##   expression      min   median `itr/sec` mem_alloc `gc/sec`
    ##   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
    ## 1 contains   406.82ms  445.4ms     2.24   471.65KB    0.224
    ## 2 grepl         2.01s    2.15s     0.465  114.79MB    0.465
    ## 3 grepl_nv      6.52s    9.94s     0.103    7.66MB    7.27

Using custom R functions can be useful, but when possible, you should
use the functions provided by `polars`. See the Reference tab for a
complete list of functions.

# Streaming data

Finally, quoting [Polars User
Guide](https://pola-rs.github.io/polars-book/user-guide/concepts/streaming/):

> One additional benefit of the lazy API is that it allows queries to be
> executed in a streaming manner. Instead of processing the data
> all-at-once Polars can execute the query in batches allowing you to
> process datasets that are larger-than-memory.

To use streaming mode, we can just add `streaming = TRUE` in `collect()`
(note that this is still an alpha feature):

``` r
bench::mark(
  lazy = lazy_query$collect(),
  lazy_streaming = lazy_query$collect(streaming = TRUE),
  iterations = 20
)
```

    ## # A tibble: 2 × 6
    ##   expression          min   median `itr/sec` mem_alloc `gc/sec`
    ##   <bch:expr>     <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
    ## 1 lazy              552ms    645ms      1.53      848B        0
    ## 2 lazy_streaming    386ms    479ms      2.10      848B        0
