# Epoch

## Format

function

## Arguments

- `tu`: string option either 'ns', 'us', 'ms', 's' or 'd'

## Returns

Expr of epoch as UInt32

Get the time passed since the Unix EPOCH in the give time unit.

## Details

ns and perhaps us will exceed integerish limit if returning to R as flaot64/double.

## Examples

```r
pl$date_range(as.Date("2022-1-1"),lazy = TRUE)$dt$epoch("ns")$lit_to_s()
pl$date_range(as.Date("2022-1-1"),lazy = TRUE)$dt$epoch("ms")$lit_to_s()
pl$date_range(as.Date("2022-1-1"),lazy = TRUE)$dt$epoch("s")$lit_to_s()
pl$date_range(as.Date("2022-1-1"),lazy = TRUE)$dt$epoch("d")$lit_to_s()
```