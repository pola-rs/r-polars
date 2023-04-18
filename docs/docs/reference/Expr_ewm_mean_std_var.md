# Exponentially-weighted moving average/std/var.

## Format

Method

```r
Expr_ewm_mean(
  com = NULL,
  span = NULL,
  half_life = NULL,
  alpha = NULL,
  adjust = TRUE,
  min_periods = 1L,
  ignore_nulls = TRUE
)

Expr_ewm_std(
  com = NULL,
  span = NULL,
  half_life = NULL,
  alpha = NULL,
  adjust = TRUE,
  bias = FALSE,
  min_periods = 1L,
  ignore_nulls = TRUE
)

Expr_ewm_var(
  com = NULL,
  span = NULL,
  half_life = NULL,
  alpha = NULL,
  adjust = TRUE,
  bias = FALSE,
  min_periods = 1L,
  ignore_nulls = TRUE
)
```

## Arguments

- `com`: Specify decay in terms of center of mass, `\gamma`, with c("`\n`", "`  \\alpha = \\frac{1}{1 + \\gamma} \\; \\forall \\; \\gamma \\geq 0\n`", "`  `")
- `span`: Specify decay in terms of span, `\theta`, with `\alpha = \frac{2}{\theta + 1} \; \forall \; \theta \geq 1 `
- `half_life`: Specify decay in terms of half-life, :math:`\lambda`, with ` \alpha = 1 - \exp \left\{ \frac{ -\ln(2) }{ \lambda } \right\} `
    
    ` \forall \; \lambda > 0`
- `alpha`: Specify smoothing factor alpha directly, `0 < \alpha \leq 1`.
- `adjust`: Divide by decaying adjustment factor in beginning periods to account for imbalance in relative weightings
    
     * When `adjust=TRUE` the EW function is calculated using weights `w_i = (1 - \alpha)^i  `
     * When `adjust=FALSE` the EW function is calculated recursively by c("`\n`", "`  y_0 = x_0 \\\\\n`", "`  y_t = (1 - \\alpha)y_{t - 1} + \\alpha x_t\n`")
- `min_periods`: Minimum number of observations in window required to have a value (otherwise result is null).
- `ignore_nulls`: ignore_nulls Ignore missing values when calculating weights.
    
     * When `ignore_nulls=FALSE` (default), weights are based on absolute positions. For example, the weights of :math:`x_0` and :math:`x_2` used in calculating the final weighted average of `[`  `x_0`, None, `x_2`\`]` are `1-\alpha)^2` and `1` if `adjust=TRUE`, and `(1-\alpha)^2` and `\alpha` if `adjust=FALSE`.
     * When `ignore_nulls=TRUE`, weights are based on relative positions. For example, the weights of `x_0` and `x_2` used in calculating the final weighted average of `[`  `x_0`, None, `x_2``]` are `1-\alpha` and `1` if `adjust=TRUE`, and `1-\alpha` and `\alpha` if `adjust=FALSE`.
- `bias`: When bias=FALSE`, apply a correction to make the estimate statistically unbiased.

## Returns

Expr

Exponentially-weighted moving average/std/var.

Ewm_std

Ewm_var

## Examples

```r
pl$DataFrame(a = 1:3)$select(pl$col("a")$ewm_mean(com=1))

pl$DataFrame(a = 1:3)$select(pl$col("a")$ewm_std(com=1))
pl$DataFrame(a = 1:3)$select(pl$col("a")$ewm_std(com=1))
```