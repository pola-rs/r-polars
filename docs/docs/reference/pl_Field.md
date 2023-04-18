# Create Field

## Arguments

- `name`: string name
- `datatype`: DataType

## Returns

a list DataType with an inner DataType

Create Field

## Details

A Field is not a DataType but a name + DataType Fields are used in Structs-datatypes and Schemas to represent everything of the Series/Column except the raw values.

## Examples

```r
#make a struct
pl$Field("city_names",pl$Utf8)

# find any DataType bundled pl$dtypes
print(pl$dtypes)
```