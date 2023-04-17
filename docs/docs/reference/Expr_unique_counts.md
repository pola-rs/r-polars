# `Expr_unique_counts`

Value counts


## Description

Return a count of the unique values in the order of appearance.
 This method differs from `value_counts` in that it does not return the
 values, only the counts and might be faster


## Format

Method


## Usage

```r
Expr_unique_counts
```


## Value

Expr


## Examples

```r
pl$DataFrame(iris)$select(pl$col("Species")$unique_counts())
```


