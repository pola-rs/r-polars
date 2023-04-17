# `Expr_clip`

Clip


## Description

Clip (limit) the values in an array to a `min` and `max` boundary.


## Usage

```r
Expr_clip(min, max)
Expr_clip_min(min)
Expr_clip_max(max)
```


## Arguments

Argument      |Description
------------- |----------------
`min`     |     Minimum Value, ints and floats or any literal expression of ints and floats
`max`     |     Maximum Value, ints and floats or any literal expression of ints and floats


## Details

Only works for numerical types.
 If you want to clip other dtypes, consider writing a "when, then, otherwise"
 expression. See :func: `when` for more information.


## Value

Expr


## Examples

```r
df = pl$DataFrame(foo = c(-50L, 5L, NA_integer_,50L))
df$with_column(pl$col("foo")$clip(1L,10L)$alias("foo_clipped"))
df$with_column(pl$col("foo")$clip_min(1L)$alias("foo_clipped"))
df$with_column(pl$col("foo")$clip_max(10L)$alias("foo_clipped"))
```


