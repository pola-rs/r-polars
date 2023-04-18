# check if z is a result

```r
is_result(x)
```

## Arguments

- `x`: R object which could be a rust-like result of a list with two elements, ok and err

## Returns

bool if is a result object

check if z is a result

## Details

both ok and err being NULL encodes ok-value NULL. No way to encode an err-value NULL If both ok and err has value then this is an invalid result