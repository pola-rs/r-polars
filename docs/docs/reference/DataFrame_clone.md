# Clone a DataFrame

```r
DataFrame_clone()
```

## Returns

DataFrame

Rarely useful as DataFrame is nearly 100% immutable Any modification of a DataFrame would lead to a clone anyways.

## Examples

```r
df1 = pl$DataFrame(iris);
df2 =  df1$clone();
df3 = df1
pl$mem_address(df1) != pl$mem_address(df2)
pl$mem_address(df1) == pl$mem_address(df3)
```