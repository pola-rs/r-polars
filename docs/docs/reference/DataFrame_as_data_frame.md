# `as_data_frame`

return polars DataFrame as R data.frame

## Description

return polars DataFrame as R data.frame

## Usage

```r
<DataFrame>$as_data_frame()
# S3 method
as.data.frame.DataFrame()
```

## Arguments

| Argument | Description                        | 
| -------- | ---------------------------------- |
| `...`         | any params passed to as.data.frame | 
| `x`         | DataFrame                          | 

## Value

data.frame

data.frame

## Examples

```r
df = pl$DataFrame(iris[1:3,])
df$as_data_frame()
```


