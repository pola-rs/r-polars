data

# DataType_constructors (composite DataType's)

## Format

An object of class `list` of length 3.

```r
DataType_constructors
```

## Returns

DataType

List of all composite DataType constructors

## Details

This list is mainly used in `zzz.R`  `.onLoad` to instantiate singletons of all flag-like DataTypes.

Non-flag like DataType called composite DataTypes also carries extra information e.g. Datetime a timeunit and a TimeZone, or List which recursively carries another DataType inside. Composite DataTypes use DataType constructors.

Any DataType can be found in pl$dtypes

## Examples

```r
#constructors are finally available via pl$... or pl$dtypes$...
pl$List(pl$List(pl$Int64))
```