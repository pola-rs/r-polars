data

# Alias

## Format

An object of class `character` of length 1.

```r
Series_alias(name)
```

## Arguments

- `name`: a String as the new name

## Returns

Series

Change name of Series

## Examples

```r
pl$Series(1:3,name = "alice")$alias("bob")
```