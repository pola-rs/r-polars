# get/set columns (the names columns)

```r
RField_datatype()

DataFrame_columns()
```

## Returns

char vec of column names

char vec of column names

get/set column names of DataFrame object

get/set column names of DataFrame object

## Examples

```r
df = pl$DataFrame(iris)

#get values
df$columns

#set + get values
df$columns = letters[1:5] #<- is fine too
df$columns
df = pl$DataFrame(iris)

#get values
df$columns

#set + get values
df$columns = letters[1:5] #<- is fine too
df$columns
```