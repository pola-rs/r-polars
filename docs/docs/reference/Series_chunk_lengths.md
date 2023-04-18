data

# Lengths of Series memory chunks

## Format

An object of class `character` of length 1.

```r
Series_chunk_lengths
```

## Returns

numeric vector. Length is number of chunks. Sum of lengths is equal to size of Series.

Get the Lengths of Series memory chunks as vector.

## Examples

```r
chunked_series = c(pl$Series(1:3),pl$Series(1:10))
chunked_series$chunk_lengths()
```