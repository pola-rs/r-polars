# Validate data input for create Dataframe with pl$DataFrame

```r
is_DataFrame_data_input(x)
```

## Arguments

- `x`: any R object to test if suitable as input to DataFrame

## Returns

bool

The Dataframe constructors accepts data.frame inheritors or list of vectors and/or Series.

## Examples

```r
polars:::is_DataFrame_data_input(iris)
polars:::is_DataFrame_data_input(list(1:5,pl$Series(1:5),letters[1:5]))
```