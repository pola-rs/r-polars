# Print a polars Field

```r
## S3 method for class 'RField'
print(x, ...)
```

## Arguments

- `x`: DataType
- `...`: not used

## Returns

self

Print a polars Field

## Examples

```r
print(pl$Field("foo",pl$List(pl$UInt64)))
```