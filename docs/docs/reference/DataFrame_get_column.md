# `get_column`

Get Column (as one Series)

## Description

get one column by name as series

## Usage

```r
DataFrame_get_column(name)
```

## Arguments

| Argument | Description                         | 
| -------- | ----------------------------------- |
| `name`         | name of column to extract as Series | 

## Value

Series

## Examples

```r
df = pl$DataFrame(iris[1,])
df$get_column("Species")
```


