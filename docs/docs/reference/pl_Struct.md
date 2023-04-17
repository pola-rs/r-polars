# `Struct`

Create Struct DataType

## Description

Struct DataType Constructor

## Format

function

## Arguments

| Argument | Description       | 
| -------- | ----------------- |
| `datatype`         | an inner DataType | 

## Value

a list DataType with an inner DataType

## Examples

```r
# create a Struct-DataType
pl$List(pl$List(pl$Boolean))

# Find any DataType via pl$dtypes
print(pl$dtypes)
```


