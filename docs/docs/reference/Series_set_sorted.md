# `set_sorted`

Set sorted

## Description

Set sorted

## Usage

```r
Series_set_sorted(reverse = FALSE, in_place = FALSE)
```

## Arguments

| Argument | Description                                                                                                                                                                                                                                               | 
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `reverse`         | bool if TRUE, signals series is Descendingly sorted, otherwise Ascendingly.                                                                                                                                                                               | 
| `in_place`         | if TRUE, will set flag mutably and return NULL. Remember to use pl$set\_polars\_options(strictly\_immutable = FALSE) otherwise an error will be thrown. If FALSE will return a cloned Series with set\_flag which in the very most cases should be just fine. | 

## Value

Series invisible

## Examples

```r
s = pl$Series(1:4)$set_sorted()
s$flags
```


