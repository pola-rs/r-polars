# Slice

```r
DataFrame_slice(offset, length = NULL)
```

## Arguments

- `offset`: integer
- `length`: integer or NULL

## Returns

LazyFrame

Get a slice of this DataFrame.

## Examples

```r
pl$DataFrame(mtcars)$slice(2, 4)
mtcars[2:6,]
```