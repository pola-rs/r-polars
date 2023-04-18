# Create Struct DataType

## Format

function

## Arguments

- `datatype`: an inner DataType

## Returns

a list DataType with an inner DataType

Struct DataType Constructor

## Examples

```r
# create a Struct-DataType
pl$List(pl$List(pl$Boolean))

# Find any DataType via pl$dtypes
print(pl$dtypes)
```