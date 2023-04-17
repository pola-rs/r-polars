# `pcase`

Simple SQL CASE WHEN implementation for R


## Description

Inspired by data.table::fcase + dplyr::case_when.
 Used instead of base::switch internally.


## Usage

```r
pcase(..., or_else = NULL)
```


## Arguments

Argument      |Description
------------- |----------------
`...`     |     odd arugments are bool statements, a next even argument is returned if prior bool statement is the first true
`or_else`     |     return this if no bool statements were true


## Details

Lifecycle: perhaps replace with something written in rust to speed up a bit


## Value

any return given first true bool statement otherwise value of or_else


## Examples

```r
n = 7
polars:::pcase(
n<5,"nope",
n>6,"yeah",
or_else = stopf("failed to have a case for n=%s",n)
)
```


