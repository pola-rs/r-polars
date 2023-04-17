# `series_equal`

Are Series's equal?

## Description

Check if series is equal with another Series.

## Format

method

## Usage

```r
Series_series_equal(other, null_equal = FALSE, strict = FALSE)
```

## Arguments

| Argument | Description                                                                   | 
| -------- | ----------------------------------------------------------------------------- |
| `other`         | Series to compare with                                                        | 
| `null_equal`         | bool if TRUE, (Null==Null) is true and not Null/NA. Overridden by strict.     | 
| `strict`         | bool if TRUE, do not allow similar DataType comparison. Overrides null\_equal. | 

## Value

bool

## Examples

```r
pl$Series(1:4,"bob")$series_equal(pl$Series(1:4))
```


