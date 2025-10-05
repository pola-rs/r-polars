pl__CompatLevel <- new.env(parent = emptyenv())
class(pl__CompatLevel) <- c("polars_object")

on_load({
  env_bind_lazy(
    pl__CompatLevel,
    # TODO: call rust function (Single Source of Truth)
    newest = (function() 1L)(),
    oldest = (function() 0L)()
  )
})
