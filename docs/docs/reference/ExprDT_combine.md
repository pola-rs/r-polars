# `ExprDT_combine`

Combine Data and Time


## Description

Create a naive Datetime from an existing Date/Datetime expression and a Time.
 Each date/datetime in the first half of the interval
 is mapped to the start of its bucket.
 Each date/datetime in the second half of the interval
 is mapped to the end of its bucket.


## Format

function


## Arguments

Argument      |Description
------------- |----------------
`tm`     |     Expr or numeric or PTime, the number of epoch since or before(if negative) the Date or tm is an Expr e.g. a column of DataType 'Time' or something into an Expr.
`tu`     |     time unit of epochs, default is "us", if tm is a PTime, then tz passed via PTime.


## Details

The `tu` allows the following time time units
 the following string language:
  

*  1ns # 1 nanosecond 

*  1us # 1 microsecond 

*  1ms # 1 millisecond


## Value

Date/Datetime expr


## Examples

```r
#Using pl$PTime
pl$lit(as.Date("2021-01-01"))$dt$combine(pl$PTime("02:34:12"))$lit_to_s()
pl$lit(as.Date("2021-01-01"))$dt$combine(pl$PTime(3600 * 1.5, tu="s"))$lit_to_s()
pl$lit(as.Date("2021-01-01"))$dt$combine(pl$PTime(3600 * 1.5E6 + 123, tu="us"))$lit_to_s()

#pass double and set tu manually
pl$lit(as.Date("2021-01-01"))$dt$combine(3600 * 1.5E6 + 123, tu="us")$lit_to_s()

#if needed to convert back to R it is more intuitive to set a specific time zone
expr = pl$lit(as.Date("2021-01-01"))$dt$combine(3600 * 1.5E6 + 123, tu="us")
expr$cast(pl$Datetime(tu = "us", tz = "GMT"))$to_r()
```


