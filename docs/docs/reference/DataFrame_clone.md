# `clone`

Clone a DataFrame

## Description

Rarely useful as DataFrame is nearly 100% immutable
Any modification of a DataFrame would lead to a clone anyways.

## Usage

```r
DataFrame_clone()
```

## Value

DataFrame

## Examples

```r
df1 = pl$DataFrame(iris);
df2 =  df1$clone();
df3 = df1
pl$mem_address(df1) != pl$mem_address(df2)
pl$mem_address(df1) == pl$mem_address(df3)
```


