# `Expr_head`

Head


## Description

Get the head n elements.
 Similar to R head(x)


## Usage

```r
Expr_head(n = 10)
```


## Arguments

Argument      |Description
------------- |----------------
`n`     |     numeric number of elements to select from head


## Value

Expr


## Examples

```r
#get 3 first elements
pl$DataFrame(list(x=1:11))$select(pl$col("x")$head(3))
```


