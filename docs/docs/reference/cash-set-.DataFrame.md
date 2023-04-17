# `$<-.DataFrame`

generic setter method


## Description

set value of properties of DataFrames


## Usage

```r
list(list("$"), list("DataFrame"))(self, name) <- value
```


## Arguments

Argument      |Description
------------- |----------------
`self`     |     DataFrame
`name`     |     name method/property to set
`value`     |     value to insert


## Details

settable polars object properties may appear to be R objects, but they are not.
 See [[method_name]] example


## Value

value


## Examples

```r
#For internal use
#is only activated for following methods of DataFrame
ls(polars:::DataFrame.property_setters)

#specific use case for one object property 'columns' (names)
df = pl$DataFrame(iris)

#get values
df$columns

#set + get values
df$columns = letters[1:5] #<- is fine too
df$columns

# Rstudio is not using the standard R code completion tool
# and it will backtick any special characters. It is possible
# to completely customize the R / Rstudio code completion except
# it will trigger Rstudio to backtick any completion! Also R does
# not support package isolated customization.


#Concrete example if tabbing on 'df$' the raw R suggestion is df$columns<-
#however Rstudio backticks it into df$`columns<-`
#to make life simple, this is valid polars syntax also, and can be used in fast scripting
df$`columns<-` = letters[5:1]

#for stable code prefer e.g.  df$columns = letters[5:1]

#to see inside code of a property use the [[]] syntax instead
df[["columns"]] # to see property code, .pr is the internal polars api into rust polars
polars:::DataFrame.property_setters$columns #and even more obscure to see setter code
```


