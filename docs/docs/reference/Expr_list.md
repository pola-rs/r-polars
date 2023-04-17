# `Expr_list`

Wrap column in list


## Description

Aggregate to list.


## Format

a method


## Usage

```r
Expr_list
```


## Details

use to_struct to wrap a DataFrame


## Value

Expr


## Examples

```r
pl$select(pl$lit(1:4)$list(), pl$lit(c("a")))
```


