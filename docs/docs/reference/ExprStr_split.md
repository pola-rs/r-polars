# split

## Arguments

- `by`: Substring to split by.
- `inclusive`: If True, include the split character/string in the results.

## Returns

List of Utf8 type

Split the string by a substring.

## Examples

```r
df = pl$DataFrame(s = c("foo bar", "foo-bar", "foo bar baz"))
df$select( pl$col("s")$str$split(by=" "))
```