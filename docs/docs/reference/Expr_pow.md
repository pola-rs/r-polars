# `Expr_pow`

Exponentiation `^` or **


## Description

Raise expression to the power of exponent.


## Usage

```r
Expr_pow(exponent)
```


## Arguments

Argument      |Description
------------- |----------------
`exponent`     |     exponent


## Value

Expr


## Examples

```r
pl$DataFrame(a= -1:3)$select(
pl$lit(2)$pow(pl$col("a"))
)$get_column("literal")$to_r()== 2^(-1:3)

pl$DataFrame(a = -1:3)$select(
pl$lit(2) ^ (pl$col("a"))
)$get_column("literal")$to_r()== 2^(-1:3)
```


