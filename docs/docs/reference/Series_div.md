# `div`

div Series

## Description

Series arithmetics

## Usage

```r
Series_div(other)
list(list("/"), list("Series"))(s1, s2)
```

## Arguments

| Argument | Description                   | 
| -------- | ----------------------------- |
| `other`         | Series or into Series         | 
| `s1`         | lhs Series                    | 
| `s2`         | rhs Series or any into Series | 

## Value

Series

## Examples

```r
pl$Series(1:3)$div(11:13)
pl$Series(1:3)$div(pl$Series(11:13))
pl$Series(1:3)$div(1L)
2L / pl$Series(1:3)
pl$Series(1:3) / 2L
```


