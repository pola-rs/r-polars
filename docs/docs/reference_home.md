# Reference

`polars`' functions are divided in several categories.

- functions that can be applied directly on `DataFrame` and `LazyFrame` (or
  their grouped counterparts `GroupBy` and `LazyGroupBy`). Note that *not all
  methods for `DataFrame`s are available for `GroupBy`*.
  
- functions for `Series` (~ R vectors)

- functions that we can apply to specific columns. These are of the form
  `pl$col("<colname>")$<type>$<fn>()` with:

    * `<colname>`: the column(s) on which we want to apply the function
    * `<type>`: the type of input that can receive this function
    * `<fn>`: the function name
  
Each subsection in the `Expr` section correspond to one type:

* Array: `arr`
* DateTime: `dt`
* String: `str`
[... TODO]

For example, suppose we want to use the function `concat()`. We could do this as
follows:

```r
# Create the DataFrame
df = pl$DataFrame(foo = c("1", NA, 2))

df$select(pl$col("foo")$str$concat("-"))
```

We know that `concat()` applies to strings, so we prefix the call to `concat()`
with `$str`.
