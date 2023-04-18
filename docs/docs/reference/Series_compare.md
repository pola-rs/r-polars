# Compare Series

```r
Series_compare(other, op)

## S3 method for class 'Series'
s1 == s2

## S3 method for class 'Series'
s1 != s2

## S3 method for class 'Series'
s1 < s2

## S3 method for class 'Series'
s1 > s2

## S3 method for class 'Series'
s1 <= s2

## S3 method for class 'Series'
s1 >= s2
```

## Arguments

- `other`: A Series or something a Series can be created from
- `op`: the chosen operator a String either: 'equal', 'not_equal', 'lt', 'gt', 'lt_eq' or 'gt_eq'
- `s1`: lhs Series
- `s2`: rhs Series or any into Series

## Returns

Series

compare two Series

## Examples

```r
pl$Series(1:5) == pl$Series(c(1:3,NA_integer_,10L))
```