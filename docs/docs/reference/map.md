# map an Err part of Result

*Source: [R/rust_result.R](https://github.com/pola-rs/r-polars/tree/main/R/rust_result.R)*

```r
map(x, f)
```

## Arguments

- `x`: any R object
- `f`: a closure that takes the ok part as input

## Returns

same R object wrapped in a Err-result

map an Err part of Result