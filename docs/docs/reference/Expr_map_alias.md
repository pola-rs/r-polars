# `Expr_map_alias`

Map alias of expression with an R function


## Description

Rename the output of an expression by mapping a function over the root name.


## Usage

```r
Expr_map_alias(fun)
```


## Arguments

Argument      |Description
------------- |----------------
`fun`     |     an R function which takes a string as input and return a string


## Value

Expr


## Examples

```r
pl$DataFrame(list(alice=1:3))$select(
pl$col("alice")$alias("joe_is_not_root")$map_alias(\(x) paste0(x,"_and_bob"))
)
```


