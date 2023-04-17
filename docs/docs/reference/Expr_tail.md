# `Expr_tail`

Tail


## Description

Get the tail n elements.
 Similar to R tail(x)


## Usage

```r
Expr_tail(n = 10)
```


## Arguments

Argument      |Description
------------- |----------------
`n`     |     numeric number of elements to select from tail


## Value

Expr


## Examples

```r
#get 3 last elements
pl$DataFrame(list(x=1:11))$select(pl$col("x")$tail(3))
```


