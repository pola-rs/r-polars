# cast_time_unit

## Format

function

## Arguments

- `tu`: string option either 'ns', 'us', or 'ms'

## Returns

Expr of i64

Cast the underlying data to another time unit. This may lose precision. The corresponding global timepoint will stay unchanged +/- precision.

## Examples

```r
df = pl$DataFrame(
  date = pl$date_range(low = as.Date("2001-1-1"), high = as.Date("2001-1-3"), interval = "1d")
)
df$select(
  pl$col("date"),
  pl$col("date")$dt$cast_time_unit()$alias("cast_time_unit_ns"),
  pl$col("date")$dt$cast_time_unit(tu="ms")$alias("cast_time_unit_ms")
)
```