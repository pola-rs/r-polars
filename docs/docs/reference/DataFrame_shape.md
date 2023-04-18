# Shape of DataFrame

```r
DataFrame_shape()
```

## Returns

two length numeric vector of c(nrows,ncols)

Get shape/dimensions of DataFrame

## Examples

```r
df = pl$DataFrame(iris)$shape
```