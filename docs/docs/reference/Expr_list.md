data

# Wrap column in list

## Format

a method

```r
Expr_list
```

## Returns

Expr

Aggregate to list.

## Details

use to_struct to wrap a DataFrame

## Examples

```r
pl$select(pl$lit(1:4)$list(), pl$lit(c("a")))
```