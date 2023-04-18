# Polars Expr

```r
Expr_lit(x)

Expr_suffix(suffix)

Expr_prefix(prefix)

Expr_reverse()
```

## Arguments

- `x`: an R Scalar, or R vector/list (via Series) into Expr
- `suffix`: string suffix to be added to a name
- `prefix`: string suffix to be added to a name

## Returns

Expr, literal of that value

Expr

Expr

Expr

Polars pl$Expr

## Details

pl$lit(NULL) translates into a typeless polars Null

## Examples

```r
2+2
#Expr has the following methods/constructors
ls(polars:::Expr)

pl$col("this_column")$sum()$over("that_column")
#scalars to literal, explit `pl$lit(42)` implicit `+ 2`
pl$col("some_column") / pl$lit(42) + 2

#vector to literal explicitly via Series and back again
#R vector to expression and back again
pl$select(pl$lit(pl$Series(1:4)))$to_list()[[1L]]

#r vecot to literal and back r vector
pl$lit(1:4)$to_r()

#r vector to literal to dataframe
pl$select(pl$lit(1:4))

#r vector to literal to Series
pl$lit(1:4)$lit_to_s()

#vectors to literal implicitly
(pl$lit(2) + 1:4 ) / 4:1
pl$col("some")$suffix("_column")
pl$col("some")$suffix("_column")
pl$DataFrame(list(a=1:5))$select(pl$col("a")$reverse())
```