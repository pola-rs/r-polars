# `clone`

Clone a Series

## Description

Rarely useful as Series are nearly 100% immutable
Any modification of a Series should lead to a clone anyways.

## Format

An object of class `character` of length 1.

## Usage

```r
Series_clone
```

## Value

Series

## Examples

```r
s1 = pl$Series(1:3);
s2 =  s1$clone();
s3 = s1
pl$mem_address(s1) != pl$mem_address(s2)
pl$mem_address(s1) == pl$mem_address(s3)
```


