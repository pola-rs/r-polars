# decode

*Source: [R/expr__binary.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__binary.R)*

## Arguments

- `encoding`: binary choice either 'hex' or 'base64'
- `strict`: Raise an error if the underlying value cannot be decoded, otherwise mask out with a null value.

## Returns

binary array with values decoded using provided encoding

Decode a value using the provided encoding.