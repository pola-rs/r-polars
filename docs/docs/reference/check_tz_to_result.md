# `check_tz_to_result`

Verify correct time zone


## Description

Verify correct time zone


## Usage

```r
check_tz_to_result(tz, allow_null = TRUE)
```


## Arguments

Argument      |Description
------------- |----------------
`tz`     |     time zone string or NULL
`allow_null`     |     bool, if TRUE accept NULL


## Value

a result object, with either a valid string or an Err


## Examples

```r
check_tz_to_result = polars:::check_tz_to_result # expose internal
#return Ok
check_tz_to_result("GMT")
check_tz_to_result(NULL)

#return Err
check_tz_to_result("Alice")
check_tz_to_result(42)
check_tz_to_result(NULL, allow_null = FALSE)
```


