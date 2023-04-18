data

# polars-API: private calls to rust-polars

## Format

An object of class `environment` of length 16.

```r
.pr
```

`.pr`

Original extendr bindings converted into pure functions

## Examples

```r
#.pr$DataFrame$print() is an external function where self is passed as arg
polars:::.pr$DataFrame$print(self = pl$DataFrame(iris))
polars:::print_env(.pr,".pr the collection of private method calls to rust-polars")
```