# strftime

## Format

function

## Arguments

- `fmt`: string format very much like in R passed to chrono

## Returns

Date/Datetime expr

Format Date/Datetime with a formatting rule. See `chrono strftime/strptime<https://docs.rs/chrono/latest/chrono/format/strftime/index.html>`_.

## Examples

```r
pl$lit(as.POSIXct("2021-01-02 12:13:14",tz="GMT"))$dt$strftime("this is the year: %Y")$to_r()
```