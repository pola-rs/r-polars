# print When

```r
## S3 method for class 'WhenThen'
print(x, ...)
```

## Arguments

- `x`: When object
- `...`: not used

## Returns

self

print When

## Examples

```r
print(pl$when(pl$col("a")>2)$then(pl$lit("more than two")))
```