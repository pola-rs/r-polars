tst_cols = list(
  fin = rep(1, 7 ),
  inf = c(rep(-Inf,4),rep(Inf,3)),
  nan = rep(NaN, 7),
  nul = rep(NA_real_,7),
  inf_fin = c(-Inf, rep(1, 5), Inf),
  nan_fin = c(NaN, rep(1, 5), NaN),
  nul_fin = c(NA_real_, rep(1,5), NA_real_),
  nan_inf_fin = c(NaN, -Inf, rep(1, 3), Inf, NaN),
  nul_inf_fin = c(NA_real_, -Inf, rep(1,3 ), Inf, NA_real_),
  nul_nan_inf_fin = c(NA_real_, NaN, -Inf, 1, Inf, NaN, NA_real_)
)

tst_funs = list(
  #scalar: poison
  sum = sum,
  mean = mean,
  product = prod,
  std = sd,
  var = var,

  #cumulative: poison
  cumsum = \(x) tail(cumsum(x),1),
  cumprod = \(x) tail(cumprod(x),1),

  #scalar: ranking + poison
  min = min,
  max = max,
  arg_min_take = \(x) x[which.min(x)],
  arg_max_take = \(x) x[which.max(x)],

  arg_min_take = \(x) x[which(min(x)==x)[1L]],
  arg_max_take = \(x) x[which(max(x)==x)[1L]],

  #cumulative: ranking + poison
  cummin= \(x) tail(cummin(x),1),
  cummax = \(x) tail(cummax(x),1)
)


df = do.call(
  rbind,
  napply(
    tst_funs,
    \(f,fname) c(list(literal = fname),lapply(tst_cols, \(col) f(col)))
  )
)

View(df)
