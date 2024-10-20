# The env for storing group_by methods
polars_groupby__methods <- new.env(parent = emptyenv())

wrap_to_group_by <- function(x, by, maintain_order) {
  self <- new.env(parent = emptyenv())
  self$df <- x
  self$by <- by
  self$maintain_order <- maintain_order

  lapply(names(polars_groupby__methods), function(name) {
    fn <- polars_groupby__methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- c("polars_group_by", "polars_object")
  self
}

groupby__agg <- function(...) {
  self$df$lazy()$group_by(
    !!!self$by,
    .maintain_order = self$maintain_order
  )$agg(...)$collect(no_optimization = TRUE) |>
    wrap()
}

groupby__head <- function(n = 5) {
  self$df$lazy()$group_by(
    !!!self$by,
    .maintain_order = self$maintain_order
  )$head(n)$collect(no_optimization = TRUE) |>
    wrap()
}

groupby__tail <- function(n = 5) {
  self$df$lazy()$group_by(
    !!!self$by,
    .maintain_order = self$maintain_order
  )$tail(n)$collect(no_optimization = TRUE) |>
    wrap()
}
