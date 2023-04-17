# `RField_name`

get/set Field name


## Description

get/set Field name


## Usage

```r
RField_name()
```


## Value

name


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


