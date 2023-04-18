# Select from an empty DataFrame

## Format

method

## Returns

DataFrame

Select from an empty DataFrame

## Details

param ... expressions passed to select `pl$select` is a shorthand for `pl$DataFrame(list())$select`

NB param of this function

## Examples

```r
pl$select(
  pl$lit(1:4)$alias("ints"),
  pl$lit(letters[1:4])$alias("letters")
)
```