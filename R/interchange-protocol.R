pl__CompatLevel <- new.env(parent = emptyenv())
class(pl__CompatLevel) <- c("polars_object")

on_load({
  env_bind_lazy(
    pl__CompatLevel,
    .range = (function() compat_level_range())(),
    oldest = (function() pl__CompatLevel$.range[1])(),
    newest = (function() pl__CompatLevel$.range[2])(),
  )
})
