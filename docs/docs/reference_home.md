# Reference
    
`polars` provides a large number of functions for numerous data types and this
can sometimes be a bit overwhelming. Overall, you should be able to do anything
you want with `polars` by specifying the **data structure** you want to use and 
then by applying **expressions** in a particular **context**.


## Data structure

As explained in some vignettes, one of `polars`' biggest strengths is the ability
to choose between eager and lazy evaluation, that require respectively a 
`DataFrame` and a `LazyFrame` (with their counterparts `GroupBy` and `LazyGroupby`
for grouped data). Most (but not all!) functions that can be applied to `DataFrame`s
can also be used on `LazyFrame`s.

Another common data structure is the `Serie`, which can be considered as the 
equivalent of R vectors in `polars`' world.

Once you know with which structure you want to work, you can modify it by using
various expressions in different contexts.



## Contexts

A context simply is the type of data modification that is done. It can be filtering
data, selecting columns or creating new ones, among other things. For example, to create new columns or modify existing ones, we need to use `with_columns()`.

Inside each context, you can use various expressions.



## Expressions

`polars` is quite verbose and requires you to be very explicit on the operations
you want to perform. This can be seen in the way expressions work.

Expressions always start with the columns that are concerned by the expression.
In summary, expressions are of the form `pl$col("<colname>")$<type>$<fn>()` with:

  * `<colname>`: the column(s) on which we want to apply the function
  * `<type>`: the type of input that can receive this function
  * `<fn>`: the function name

For example, suppose we have a column with strings that represent dates and that
we want to extract the year from these dates:

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

Similarly, to convert text to uppercase, we use the `str` prefix before using
`to_uppercase()`:


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

Each subsection in the "Expressions" section correspond to one type:

* Array: `arr`
* DateTime: `dt`
* String: `str`
[... TODO]

