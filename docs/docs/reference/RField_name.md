# get/set Field name

```r
RField_name()
```

## Returns

name

get/set Field name

## Examples

```r
field = pl$Field("Cities",pl$Utf8)

#get name / datatype
field$name
field$datatype

#set + get values
field$name = "CityPoPulations" #<- is fine too
field$datatype = pl$UInt32

print(field)
```