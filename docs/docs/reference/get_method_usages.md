# Generate autocompletion suggestions for object

```r
get_method_usages(env, pattern = "")
```

## Arguments

- `env`: environment to extract usages from
- `pattern`: string passed to ls(pattern) to subset methods by pattern

## Returns

method usages

Generate autocompletion suggestions for object

## Details

used internally for auto completion in .DollarNames methods

## Examples

```r
polars:::get_method_usages(polars:::DataFrame, pattern="col")
```