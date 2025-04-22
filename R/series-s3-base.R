#' @export
print.polars_series <- function(x, ...) {
  x$`_s`$as_str() |>
    writeLines()
  invisible(x)
}

#' @export
`[.polars_namespace_series_struct` <- `[.polars_namespace_expr_struct`

# Copied from https://github.com/pola-rs/r-polars/blob/ebfeed44f7b81980b1693c3dc1539d7217b593b4/R/series__series.R#L167-L174 # nolint
# TODO: recheck
METHODS_EXCLUDE <- c(
  "agg_groups",
  "exclude",
  "inspect",
  "over",
  "rolling"
)

# Special case of the dollar method because dispatching allowed expr methods
#' @export
`$.polars_series` <- function(x, name) {
  member_names <- ls(x, all.names = TRUE)
  method_names <- names(polars_series__methods)
  dispatched_method_names <- names(polars_expr__methods) |>
    setdiff(METHODS_EXCLUDE)

  if (name %in% member_names) {
    env_get(x, name)
  } else if (name %in% method_names) {
    fn <- polars_series__methods[[name]]
    # nolint start: object_usage_linter
    self <- x
    # nolint end
    environment(fn) <- environment()
    fn
  } else if (name %in% dispatched_method_names) {
    fn <- polars_expr__methods[[name]]
    expr_wrap_function_factory(fn, x, namespace = NULL)
  } else {
    NextMethod()
  }
}

# Special case of the dollar method because dispatching allowed expr methods
#' @exportS3Method utils::.DollarNames
`.DollarNames.polars_series` <- function(x, pattern = "") {
  member_names <- ls(x, all.names = TRUE)
  method_names <- names(polars_series__methods)
  dispatched_method_names <- names(polars_expr__methods) |>
    setdiff(METHODS_EXCLUDE)

  all_names <- union(member_names, method_names) |>
    union(dispatched_method_names)
  filtered_names <- findMatches(pattern, all_names)

  filtered_names[!startsWith(filtered_names, "_")]
}

# TODO: support the mode argument
#' @export
as.vector.polars_series <- function(x, mode = "any") {
  x$to_r_vector(ensure_vector = TRUE) |>
    as.vector(mode = mode)
}

# TODO: as.character.polars_series

#' @export
length.polars_series <- function(x) x$len()

#' @export
max.polars_series <- function(x, ...) x$max()

#' @export
min.polars_series <- function(x, ...) x$min()

#' @export
mean.polars_series <- function(x, ...) x$mean()

#' @exportS3Method stats::median
median.polars_series <- function(x, ...) x$median()

#' @export
sum.polars_series <- function(x, ...) x$sum()
