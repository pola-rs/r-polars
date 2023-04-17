# `Expr_cast`

Cast between DataType(s)


## Description

Cast between DataType(s)


## Usage

```r
Expr_cast(dtype, strict = TRUE)
```


## Arguments

Argument      |Description
------------- |----------------
`dtype`     |     DataType to cast to.
`strict`     |     bool if true an error will be thrown if cast failed at resolve time.


## Value

Expr


## Examples

```r
df = pl$DataFrame(list(a = 1:3, b = 1:3))
df$with_columns(
pl$col("a")$cast(pl$dtypes$Float64, TRUE),
pl$col("a")$cast(pl$dtypes$Int32, TRUE)
)
```


