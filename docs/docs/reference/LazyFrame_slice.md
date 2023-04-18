# Slice

```r
LazyFrame_slice(offset, length = NULL)
```

## Arguments

- `offset`: integer
- `length`: integer or NULL

## Returns

DataFrame

Get a slice of this DataFrame.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$slice(2, 4)$collect()
pl$DataFrame(mtcars)$lazy()$slice(30)$collect()
mtcars[2:6,]
```