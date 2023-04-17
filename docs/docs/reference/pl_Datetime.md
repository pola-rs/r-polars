# `pl_Datetime`

Create Datetime DataType


## Description

Datetime DataType constructor


## Format

function


## Arguments

Argument      |Description
------------- |----------------
`tu`     |     string option either "ms", "us" or "ns"
`tz`     |     string the Time Zone, see details


## Details

all allowed TimeZone designations can be found in `base::OlsonNames()`


## Value

Datetime DataType


## Examples

```r
pl$Datetime("ns","Pacific/Samoa")
```


