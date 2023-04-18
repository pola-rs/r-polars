data

# print LazyFrame internal method

## Format

An object of class `character` of length 1.

```r
LazyFrame_print(x)
```

## Arguments

- `x`: LazyFrame

## Returns

self

can be used i the middle of a method chain

## Examples

```r
pl$DataFrame(iris)$lazy()$print()
```