# `arr_get`

Get list


## Description

Get the value by index in the sublists.


## Format

function


## Usage

```r
list(list("["), list("ExprArrNameSpace"))(x, index)
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     ExprArrNameSpace
`index`     |     value to get


## Details

[.ExprArrNameSpace used as e.g. `pl$col("a")$arr[0]` same as `pl$col("a")$get(0)`


## Value

Expr


## Examples

```r
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
df$select(pl$col("a")$arr$get(0))
df$select(pl$col("a")$arr$get(c(2,0,-1)))
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
df$select(pl$col("a")$arr[0])
df$select(pl$col("a")$arr[c(2,0,-1)])
```


