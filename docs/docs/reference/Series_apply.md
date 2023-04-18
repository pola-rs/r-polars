# Apply every value with an R fun

```r
Series_apply(
  fun,
  datatype = NULL,
  strict_return_type = TRUE,
  allow_fail_eval = FALSE
)
```

## Arguments

- `fun`: r function, should take a scalar value as input and return one.
- `datatype`: DataType of return value. Default NULL means same as input.
- `strict_return_type`: bool, default TRUE: fail on wrong return type, FALSE: convert to polars Null
- `allow_fail_eval`: bool, default FALSE: raise R fun error, TRUE: convert to polars Null

## Returns

Series

About as slow as regular non-vectorized R. Similar to using R sapply on a vector.

## Examples

```r
s = pl$Series(letters[1:5],"ltrs")
f = \(x) paste(x,":",as.integer(charToRaw(x)))
s$apply(f,pl$Utf8)

#same as
pl$Series(sapply(s$to_r(),f),s$name)
```