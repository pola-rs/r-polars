# `to_Struct_unnest`

to\_struct and unnest again

## Description

to\_struct and unnest again

Unnest a DataFrame struct columns.

## Usage

```r
DataFrame_to_struct(name = "")
DataFrame_unnest(names = NULL)
```

## Arguments

| Argument | Description                                                              | 
| -------- | ------------------------------------------------------------------------ |
| `name`         | name of new Series                                                       | 
| `names`         | names of struct columns to unnest, default NULL unnest any struct column | 

## Value

@to\_struct() returns a Series

$unnest() returns a DataFrame with all column including any that has been unnested

## Examples

```r
#round-trip conversion from DataFrame with two columns
df = pl$DataFrame(a=1:5,b=c("one","two","three","four","five"))
s = df$to_struct()
s
s$to_r() # to r list
df_s = s$to_frame() #place series in a new DataFrame
df_s$unnest() # back to starting df
```


