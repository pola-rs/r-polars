# map an ok-value or pass on an err-value

*Source: [R/rust_result.R](https://github.com/pola-rs/r-polars/tree/main/R/rust_result.R)*

```r
and_then(x, f)
```

## Arguments

- `x`: any R object
- `f`: a closure that takes the ok part as input

## Returns

same R object wrapped in a Err-result

map an ok-value or pass on an err-value