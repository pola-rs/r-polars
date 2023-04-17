# `estimated_size`

Estimated size

## Description

Return an estimation of the total (heap) allocated size of the DataFrame.

## Format

function

## Usage

```r
DataFrame_estimated_size
```

## Value

Bytes

## Examples

```r
pl$DataFrame(mtcars)$estimated_size()
```


