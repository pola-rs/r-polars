# Create new DataFrame

## Arguments

- `...`:  * one data.frame or something that inherits data.frame or DataFrame
     * one list of mixed vectors and Series of equal length
     * mixed vectors and/or Series of equal length
    
    Columns will be named as of named arguments or alternatively by names of Series or given a placeholder name.
- `make_names_unique`: default TRUE, any duplicated names will be prefixed a running number
- `parallel`: bool default FALSE, experimental multithreaded interpretation of R vectors into a polars DataFrame. This is experimental as multiple threads read from R mem simultaneously. So far no issues parallel read from R has been found.

## Returns

DataFrame

Create new DataFrame

## Examples

```r
pl$DataFrame(
  a = list(c(1,2,3,4,5)), #NB if first column should be a list, wrap it in a Series
  b = 1:5,
  c = letters[1:5],
  d = list(1:1,1:2,1:3,1:4,1:5)
) #directly from vectors

#from a list of vectors or data.frame
pl$DataFrame(list(
  a= c(1,2,3,4,5),
  b=1:5,
  c = letters[1:5],
  d = list(1L,1:2,1:3,1:4,1:5)
))
```