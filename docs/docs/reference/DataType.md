# DataTypes polars types

`DataType` any polars type (ported so far)

## Examples

```r
print(ls(pl$dtypes))
pl$dtypes$Float64
pl$dtypes$Utf8

pl$List(pl$List(pl$UInt64))

pl$Struct(pl$Field("CityNames", pl$Utf8))

# Some DataType use case, this user function fails because....
## Not run:

  pl$Series(1:4)$apply(\(x) letters[x])
## End(Not run)

#The function changes type from Integer(Int32)[Integers] to char(Utf8)[Strings]
#specifying the output DataType: Utf8 solves the problem
pl$Series(1:4)$apply(\(x) letters[x],datatype = pl$dtypes$Utf8)
```