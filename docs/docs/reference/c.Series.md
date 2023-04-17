# `c.Series`

Immutable combine series


## Description

Immutable combine series


## Usage

```r
list(list("c"), list("Series"))(x, ...)
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     a Series
`...`     |     Series(s) or any object into Series meaning `pl$Series(object)` returns a series


## Details

append datatypes has to match. Combine does not rechunk.
 Read more about R vectors, Series and chunks in [`docs_translations`](#docstranslations) :


## Value

a combined Series


## Examples

```r
s = c(pl$Series(1:5),3:1,NA_integer_)
s$chunk_lengths() #the series contain three unmerged chunks
```


