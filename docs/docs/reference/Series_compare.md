# `compare`

Compare Series

## Description

compare two Series

## Usage

```r
Series_compare(other, op)
list(list("=="), list("Series"))(s1, s2)
list(list("!="), list("Series"))(s1, s2)
list(list("<"), list("Series"))(s1, s2)
list(list(">"), list("Series"))(s1, s2)
list(list("<="), list("Series"))(s1, s2)
list(list(">="), list("Series"))(s1, s2)
```

## Arguments

| Argument | Description                                                                               | 
| -------- | ----------------------------------------------------------------------------------------- |
| `other`         | A Series or something a Series can be created from                                        | 
| `op`         | the chosen operator a String either: 'equal', 'not\_equal', 'lt', 'gt', 'lt\_eq' or 'gt\_eq' | 
| `s1`         | lhs Series                                                                                | 
| `s2`         | rhs Series or any into Series                                                             | 

## Value

Series

## Examples

```r
pl$Series(1:5) == pl$Series(c(1:3,NA_integer_,10L))
```


