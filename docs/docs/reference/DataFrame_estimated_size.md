# Estimated size

## Format

function

```r
DataFrame_estimated_size
```

## Returns

Bytes

Return an estimation of the total (heap) allocated size of the DataFrame.

## Examples

```r
pl$DataFrame(mtcars)$estimated_size()
```