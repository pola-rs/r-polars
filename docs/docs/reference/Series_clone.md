data

# Clone a Series

## Format

An object of class `character` of length 1.

```r
Series_clone
```

## Returns

Series

Rarely useful as Series are nearly 100% immutable Any modification of a Series should lead to a clone anyways.

## Examples

```r
s1 = pl$Series(1:3);
s2 =  s1$clone();
s3 = s1
pl$mem_address(s1) != pl$mem_address(s2)
pl$mem_address(s1) == pl$mem_address(s3)
```