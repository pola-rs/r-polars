# `Expr_top_k`

Top k values


## Description

Return the `k` largest elements.
 If 'reverse=True` the smallest elements will be given.


## Format

a method


## Usage

```r
Expr_top_k(k, reverse = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
`k`     |     numeric k top values to get
`reverse`     |     bool if true then k smallest values


## Details

This has time complexity: $ O(n + k \\log{}n - \frac{k}{2}) $ 
 
 See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Expr


## Examples

```r
pl$DataFrame(list(
a = c(6, 1, 0, NA, Inf, NaN)
))$select(pl$col("a")$top_k(5))
```


