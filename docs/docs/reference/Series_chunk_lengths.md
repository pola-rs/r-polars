# `chunk_lengths`

Lengths of Series memory chunks

## Description

Get the Lengths of Series memory chunks as vector.

## Format

An object of class `character` of length 1.

## Usage

```r
Series_chunk_lengths
```

## Value

numeric vector. Length is number of chunks. Sum of lengths is equal to size of Series.

## Examples

```r
chunked_series = c(pl$Series(1:3),pl$Series(1:10))
chunked_series$chunk_lengths()
```


