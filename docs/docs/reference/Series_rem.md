# `rem`

rem Series

## Description

Series arithmetics, remainder

## Usage

```r
Series_rem(other)
```

## Arguments

| Argument | Description           | 
| -------- | --------------------- |
| `other`         | Series or into Series | 

## Value

Series

## Examples

```r
pl$Series(1:4)$rem(2L)
pl$Series(1:3)$rem(pl$Series(11:13))
pl$Series(1:3)$rem(1L)
```


