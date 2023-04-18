# Create Datetime DataType

## Format

function

## Arguments

- `tu`: string option either "ms", "us" or "ns"
- `tz`: string the Time Zone, see details

## Returns

Datetime DataType

Datetime DataType constructor

## Details

all allowed TimeZone designations can be found in `base::OlsonNames()`

## Examples

```r
pl$Datetime("ns","Pacific/Samoa")
```