# `Expr_value_counts`

Value counts


## Description

Count all unique values and create a struct mapping value to count.


## Format

Method


## Usage

```r
Expr_value_counts(multithreaded = FALSE, sort = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
`multithreaded`     |     Better to turn this off in the aggregation context, as it can lead to contention.
`sort`     |     Ensure the output is sorted from most values to least.


## Value

Expr


## Examples

```r
df = pl$DataFrame(iris)$select(pl$col("Species")$value_counts())
df
df$unnest()$as_data_frame() #recommended to unnest structs before converting to R
```


