# split_exact

## Arguments

- `by`: Substring to split by.
- `n`: Number of splits to make.
- `inclusive`: If True, include the split_exact character/string in the results.

## Returns

Struct where each of n+1 fields is of Utf8 type

Split the string by a substring using `n` splits. Results in a struct of `n+1` fields. If it cannot make `n` splits, the remaining field elements will be null.

## Examples

```r
df = pl$DataFrame(s = c("a_1", NA, "c", "d_4"))
df$select( pl$col("s")$str$split_exact(by="_",1))
```