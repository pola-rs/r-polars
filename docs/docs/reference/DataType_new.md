# DataType_new (simple DataType's)

```r
DataType_new(str)
```

## Arguments

- `str`: name of DataType to create

## Returns

DataType

Create a new flag like DataType

## Details

This function is mainly used in `zzz.R`  `.onLoad` to instantiate singletons of all flag-like DataType.

Non-flag like DataType called composite DataTypes also carries extra information e.g. Datetime a timeunit and a TimeZone, or List which recursively carries another DataType inside. Composite DataTypes use DataType constructors.

Any DataType can be found in pl$dtypes

## Examples

```r
polars:::DataType_new("Int64")
```