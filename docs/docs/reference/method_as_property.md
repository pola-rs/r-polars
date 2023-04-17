# `method_as_property`

Give a class method property behavior


## Description

Internal function, see use in source


## Usage

```r
method_as_property(f, setter = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
`f`     |     a function
`setter`     |     bool, if true a property method can be modified by user


## Value

function subclassed into c("property","function") or c("setter","property","function")


