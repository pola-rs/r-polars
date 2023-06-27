# Reference
    
`polars` provides a large number of functions for numerous data types and this
can sometimes be a bit overwhelming. Overall, you should be able to do anything
you want with `polars` by specifying the **data structure** you want to use and 
then by applying **expressions** in a particular **context**.


## Data structure

As explained in some vignettes, one of `polars` biggest strengths is the ability
to choose between eager and lazy evaluation, that require respectively a 
`DataFrame` and a `LazyFrame` (with their counterparts `GroupBy` and `LazyGroupBy`
for grouped data). 

We can apply functions directly on a `DataFrame` or `LazyFrame`, such as `rename()`
or `drop()`. Most (but not all!) functions that can be applied to `DataFrame`s
can also be used on `LazyFrame`s. Calling `<DataFrame>$lazy()` yields
a `LazyFrame`. While calling `<LazyFrame>$collect()` starts a computation and
yields a `DataFrame` as result.

Another common data structure is the `Series`, which can be considered as the 
equivalent of R vectors in `polars`' world. Therefore, a `DataFrame` is a list of
`Series`.

Operations on `DataFrame` or `LazyFrame` are useful, but many more operations
can be applied on columns themselves by using various **expressions** in different
**contexts**.



## Contexts

A context simply is the type of data modification that is done. There are 3 types
of contexts:

* select and modify columns with `select()` and `with_columns()`;
* filter rows with `filter()`;
* group and aggregate rows with `groupby()` and `agg()`

Inside each context, you can use various **expressions** (aka. `Expr`). Some expressions cannot
be used in some contexts. For example, in `with_columns()`, you can only apply
expressions that return either the same number of values or a single value that
will be duplicated on all rows:

```r
test = pl$DataFrame(mtcars)

# this works
test$with_columns(
  pl$col("mpg") + 1
)

# this doesn't work because it returns only 2 values, while mtcars has 32 rows.
test$with_columns(
  pl$col("mpg")$slice(0, 2)
)
```
By contrast, in an `agg` context, any number of return values are possible, as
they are returned in a list, and only the new columns or the grouping columns 
are returned.

```r
test$groupby(pl$col("cyl"))$agg(
  pl$col("mpg"), # varying number of values
  pl$col("mpg")$slice(0, 2)$suffix("_sliced"), # two values
  # aggregated to one value and implicitly unpacks list
  pl$col("mpg")$sum()$suffix("_summed") 
)

shape: (3, 4)
┌─────┬──────────────────────┬──────────────┬────────────┐
│ cyl ┆ mpg                  ┆ mpg_sliced   ┆ mpg_summed │
│ --- ┆ ---                  ┆ ---          ┆ ---        │
│ f64 ┆ list[f64]            ┆ list[f64]    ┆ f64        │
╞═════╪══════════════════════╪══════════════╪════════════╡
│ 4.0 ┆ [22.8, 24.4, … 21.4] ┆ [22.8, 24.4] ┆ 293.3      │
│ 8.0 ┆ [18.7, 14.3, … 15.0] ┆ [18.7, 14.3] ┆ 211.4      │
│ 6.0 ┆ [21.0, 21.0, … 19.7] ┆ [21.0, 21.0] ┆ 138.2      │
└─────┴──────────────────────┴──────────────┴────────────┘
```

## Expressions

`polars` is quite verbose and requires you to be very explicit on the operations
you want to perform. This can be seen in the way expressions work. All polars 
public functions (excluding methods) are accessed via the namespace handle `pl`.

Two important expressions starters are `pl$col()` (names a column in the context) 
and `pl$lit()` (wraps a literal value or vector/series in an Expr). Most other
expression starters are syntactic sugar derived from thereof, e.g. `pl$sum(_)` is
actually `pl$col(_)$sum()`.

Expressions can be chained with about 170 expression methods such as `$sum()` 
which aggregates e.g. the column with summing.

```r
# two examples of starting, chaining and combining expressions
pl$DataFrame(a = 1:4)$with_columns(
  # take col mpg, slice it, sum it, then cast it
  pl$col("a")$slice(0, 2)$sum()$cast(pl$Float32)$alias("a_slice_sum_cast"),
  # take 1:3, name it, then sum, then multiply with two
  pl$lit(1:3)$alias("lit_sum_add_two")$sum() * 2L,
  # similar to above, but with `mul()`-method instead of `*`.
  pl$lit(1:3)$sum()$mul(pl$col("a"))$alias("lit_sum_add_mpg") 
)
shape: (4, 4)
┌─────┬──────────────────┬─────────────────┬─────────────────┐
│ a   ┆ a_slice_sum_cast ┆ lit_sum_add_two ┆ lit_sum_add_mpg │
│ --- ┆ ---              ┆ ---             ┆ ---             │
│ i32 ┆ f32              ┆ i32             ┆ i32             │
╞═════╪══════════════════╪═════════════════╪═════════════════╡
│ 1   ┆ 3.0              ┆ 12              ┆ 6               │
│ 2   ┆ 3.0              ┆ 12              ┆ 12              │
│ 3   ┆ 3.0              ┆ 12              ┆ 18              │
│ 4   ┆ 3.0              ┆ 12              ┆ 24              │
└─────┴──────────────────┴─────────────────┴─────────────────┘
```

Moreover there are subnamespaces with special methods only applicable for a 
specific type `dt`(datetime), `arr`(list), `str`(strings), `struct`(structs),
`cat`(categoricals) and `bin`(binary). As a sidenote, there is also an exotic
subnamespace called `meta` which is rarely used to manipulate the expressions
themselves. Each subsection in the "Expressions" section lists all operations 
available for a specific subnamespace.

For a concrete example for `dt`, suppose we have a column containing dates and 
that we want to extract the year from these dates:

```r
# Create the DataFrame
df = pl$DataFrame(
  date = pl$date_range(
      as.Date("2020-01-01"),
      as.Date("2023-01-02"),
      interval = "1y"
  )
)
df

shape: (4, 1)
┌─────────────────────┐
│ date                │
│ ---                 │
│ datetime[μs]        │
╞═════════════════════╡
│ 2020-01-01 00:00:00 │
│ 2021-01-01 00:00:00 │
│ 2022-01-01 00:00:00 │
│ 2023-01-01 00:00:00 │
└─────────────────────┘
```

The function `year()` only makes sense for date-time data, so the type of input
that can receive this function is `dt` (for **d**ate-**t**ime): 

```r
df$with_columns(
  pl$col("date")$dt$year()$alias("year")
)
```

Similarly, if we have text data that we want to convert text to uppercase, we 
use the `str` prefix before using `to_uppercase()`:


```r
# Create the DataFrame
df = pl$DataFrame(foo = c("jake", "mary", "john peter"))

df$select(pl$col("foo")$str$to_uppercase())

shape: (3, 1)
┌────────────┐
│ foo        │
│ ---        │
│ str        │
╞════════════╡
│ JAKE       │
│ MARY       │
│ JOHN PETER │
└────────────┘
```
