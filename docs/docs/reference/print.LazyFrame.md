# print LazyFrame s3 method

```r
## S3 method for class 'LazyFrame'
print(x, ...)
```

## Arguments

- `x`: DataFrame
- `...`: not used

## Returns

self

print LazyFrame s3 method

## Examples

```r
print(pl$DataFrame(iris)$lazy())
```