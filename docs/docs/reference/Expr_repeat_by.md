# `Expr_repeat_by`

Repeat by


## Description

Repeat the elements in this Series as specified in the given expression.
 The repeated elements are expanded into a `List` .


## Usage

```r
Expr_repeat_by(by)
```


## Arguments

Argument      |Description
------------- |----------------
`by`     |     Expr Numeric column that determines how often the values will be repeated. The column will be coerced to UInt32. Give this dtype to make the coercion a no-op.


## Value

Expr


## Examples

```r
df = pl$DataFrame(list(a = c("x","y","z"), n = c(0:2)))
df$select(pl$col("a")$repeat_by("n"))
```


