# `Expr_hash`

hash


## Description

Hash the elements in the selection.
 The hash value is of type `UInt64` .


## Usage

```r
Expr_hash(seed = 0, seed_1 = NULL, seed_2 = NULL, seed_3 = NULL)
```


## Arguments

Argument      |Description
------------- |----------------
`seed`     |     Random seed parameter. Defaults to 0.
`seed_1`     |     Random seed parameter. Defaults to arg seed.
`seed_2`     |     Random seed parameter. Defaults to arg seed.
`seed_3`     |     Random seed parameter. Defaults to arg seed. The column will be coerced to UInt32. Give this dtype to make the coercion a no-op.


## Value

Expr


## Examples

```r
df = pl$DataFrame(iris)
df$select(pl$all()$head(2)$hash(1234)$cast(pl$Utf8))$to_list()
```


