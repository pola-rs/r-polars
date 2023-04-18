# print GroupBy

```r
## S3 method for class 'GroupBy'
print(x, ...)
```

## Arguments

- `x`: DataFrame
- `...`: not used

## Returns

self

print GroupBy

## Examples

```r
pl$DataFrame(iris)$groupby("Species")
```