# `is_DataFrame_data_input`

Validate data input for create Dataframe with pl$DataFrame


## Description

The Dataframe constructors accepts data.frame inheritors or list of vectors and/or Series.


## Usage

```r
is_DataFrame_data_input(x)
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     any R object to test if suitable as input to DataFrame


## Value

bool


## Examples

```r
polars:::is_DataFrame_data_input(iris)
polars:::is_DataFrame_data_input(list(1:5,pl$Series(1:5),letters[1:5]))
```


