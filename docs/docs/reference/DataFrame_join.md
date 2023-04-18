# join DataFrame with other DataFrame

```r
DataFrame_join(
  other,
  left_on = NULL,
  right_on = NULL,
  on = NULL,
  how = c("inner", "left", "outer", "semi", "anti", "cross"),
  suffix = "_right",
  allow_parallel = TRUE,
  force_parallel = FALSE
)
```

## Arguments

- `other`: DataFrame
- `left_on`: names of columns in self LazyFrame, order should match. Type, see on param.
- `right_on`: names of columns in other LazyFrame, order should match. Type, see on param.
- `on`: named columns as char vector of named columns, or list of expressions and/or strings.
- `how`: a string selecting one of the following methods: inner, left, outer, semi, anti, cross
- `suffix`: name to added right table
- `allow_parallel`: bool
- `force_parallel`: bool

## Returns

DataFrame

join DataFrame with other DataFrame

## Examples

```r
print(df1 <- pl$DataFrame(list(key=1:3,payload=c('f','i',NA))))
print(df2 <- pl$DataFrame(list(key=c(3L,4L,5L,NA_integer_))))
df1$join(other = df2,on = 'key')
```