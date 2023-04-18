data

# Reverse

## Format

An object of class `character` of length 1.

```r
LazyFrame_reverse
```

## Returns

LazyFrame

Reverse the DataFrame.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$reverse()$collect()
```