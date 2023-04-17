# `same_outer_datatype`

check if x is a valid RPolarsDataType


## Description

check if x is a valid RPolarsDataType


## Arguments

Argument      |Description
------------- |----------------
`lhs`     |     an RPolarsDataType
`rhs`     |     an RPolarsDataType


## Value

bool TRUE if outer datatype is the same.


## Examples

```r
# TRUE
pl$same_outer_dt(pl$Datetime("us"),pl$Datetime("ms"))
pl$same_outer_dt(pl$List(pl$Int64),pl$List(pl$Float32))

#FALSE
pl$same_outer_dt(pl$Int64,pl$Float64)
```


