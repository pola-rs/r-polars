# Verify correct time zone

```r
check_tz_to_result(tz, allow_null = TRUE)
```

## Arguments

- `tz`: time zone string or NULL
- `allow_null`: bool, if TRUE accept NULL

## Returns

a result object, with either a valid string or an Err

Verify correct time zone

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