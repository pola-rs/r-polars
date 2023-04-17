# `Field`

Create Field

## Description

Create Field

## Arguments

| Argument | Description | 
| -------- | ----------- |
| `name`         | string name | 
| `datatype`         | DataType    | 

## Details

A Field is not a DataType but a name + DataType
Fields are used in Structs-datatypes and Schemas to represent
everything of the Series/Column except the raw values.

## Value

a list DataType with an inner DataType

## Examples

```r
#make a struct
pl$Field("city_names",pl$Utf8)

# find any DataType bundled pl$dtypes
print(pl$dtypes)
```


