# Set sorted

```r
Series_set_sorted(reverse = FALSE, in_place = FALSE)
```

## Arguments

- `reverse`: bool if TRUE, signals series is Descendingly sorted, otherwise Ascendingly.
- `in_place`: if TRUE, will set flag mutably and return NULL. Remember to use pl$set_polars_options(strictly_immutable = FALSE) otherwise an error will be thrown. If FALSE will return a cloned Series with set_flag which in the very most cases should be just fine.

## Returns

Series invisible

Set sorted

## Examples

```r
s = pl$Series(1:4)$set_sorted()
s$flags
```