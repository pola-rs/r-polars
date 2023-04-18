# restruct list

```r
restruct_list(l)
```

## Arguments

- `l`: list

## Returns

restructed list

lifecycle:: Deprecate Restruct an object where structs where previously unnested

## Details

It was much easier impl export unnested struct from polars. This function restructs exported unnested structs. This function should be repalced with rust code writing this output directly before nesting. This hack relies on rust uses the tag "is_struct" to mark what should be re-structed.