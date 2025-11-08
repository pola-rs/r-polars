# Because validation step is very expensive,
# this is a copy of `props<-`, the only difference is `check = FALSE`
# https://github.com/RConsortium/S7/issues/574
`props_uncheck<-` <- function(object, value) {
  for (name in names(value)) {
    prop(object, name, check = FALSE) <- value[[name]]
  }

  object
}

# A copy of `set_props()`, using `props_uncheck<-`
# instead of `props<-` to avoid validation
set_props_uncheck <- function(object, ...) {
  props_uncheck(object) <- list(...)
  object
}
