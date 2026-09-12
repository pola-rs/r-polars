#' @rdname lazyframe__sink_parquet
#' @param min Include stats on the minimum values in the column.
#' @param max Include stats on the maximum values in the column.
#' @param distinct_count Include stats on the number of distinct values in the
#' column.
#' @param null_count Include stats on the number of null values in the column.
#'
#' @export
parquet_statistics <- function(
  ...,
  min = TRUE,
  max = TRUE,
  distinct_count = TRUE,
  null_count = TRUE
) {
  check_dots_empty0(...)
  check_bool(min)
  check_bool(max)
  check_bool(distinct_count)
  check_bool(null_count)

  structure(
    list(
      min = min,
      max = max,
      distinct_count = distinct_count,
      null_count = null_count
    ),
    class = c("polars_parquet_statistics", "list")
  )
}

#' Transforms raw percentiles into our preferred format, adding the 50th
#' percentile.
#' Raises an error if the percentile sequence is invalid (e.g. outside the
#' range `[0, 1]`).
#' @noRd
parse_percentiles <- function(percentiles, inject_median = FALSE) {
  if (!all(percentiles >= 0 & percentiles <= 1)) {
    abort("`percentiles` must all be in the range [0, 1].")
  }
  sub_50_percentiles <- percentiles[percentiles < 50] |>
    sort()
  at_or_above_50_percentiles <- percentiles[percentiles >= 50] |>
    sort()
  if (
    isTRUE(inject_median) &&
      (length(at_or_above_50_percentiles) == 0 || at_or_above_50_percentiles[1] != 0.5)
  ) {
    at_or_above_50_percentiles <- c(0.5, at_or_above_50_percentiles)
  }

  c(sub_50_percentiles, at_or_above_50_percentiles)
}

forward_old_opt_flags <- function(
  optimizations,
  type_coercion = deprecated(),
  predicate_pushdown = deprecated(),
  projection_pushdown = deprecated(),
  simplify_expression = deprecated(),
  slice_pushdown = deprecated(),
  comm_subplan_elim = deprecated(),
  comm_subexpr_elim = deprecated(),
  cluster_with_columns = deprecated(),
  collapse_joins = deprecated(),
  no_optimization = deprecated()
) {
  call <- caller_env(2L)
  warn_func <- function(arg_name) {
    deprecate_warn(
      c(
        `!` = sprintf("%s is deprecated.", format_arg(arg_name)),
        `i` = sprintf("Use %s instead.", format_arg("optimizations"))
      ),
      always = TRUE,
      user_env = call
    )
  }

  need_validation <- FALSE

  if (is_present(type_coercion)) {
    warn_func("type_coercion")
    prop(optimizations, "type_coercion", check = FALSE) <- type_coercion
    need_validation <- TRUE
  }
  if (is_present(predicate_pushdown)) {
    warn_func("predicate_pushdown")
    prop(optimizations, "predicate_pushdown", check = FALSE) <- predicate_pushdown
    need_validation <- TRUE
  }
  if (is_present(projection_pushdown)) {
    warn_func("projection_pushdown")
    prop(optimizations, "projection_pushdown", check = FALSE) <- projection_pushdown
    need_validation <- TRUE
  }
  if (is_present(simplify_expression)) {
    warn_func("simplify_expression")
    prop(optimizations, "simplify_expression", check = FALSE) <- simplify_expression
    need_validation <- TRUE
  }
  if (is_present(slice_pushdown)) {
    warn_func("slice_pushdown")
    prop(optimizations, "slice_pushdown", check = FALSE) <- slice_pushdown
    need_validation <- TRUE
  }
  if (is_present(comm_subplan_elim)) {
    warn_func("comm_subplan_elim")
    prop(optimizations, "comm_subplan_elim", check = FALSE) <- comm_subplan_elim
    need_validation <- TRUE
  }
  if (is_present(comm_subexpr_elim)) {
    warn_func("comm_subexpr_elim")
    prop(optimizations, "comm_subexpr_elim", check = FALSE) <- comm_subexpr_elim
    need_validation <- TRUE
  }
  if (is_present(cluster_with_columns)) {
    warn_func("cluster_with_columns")
    prop(optimizations, "cluster_with_columns", check = FALSE) <- cluster_with_columns
    need_validation <- TRUE
  }

  if (is_present(collapse_joins)) {
    warn_func("collapse_joins")
    # collapse_joins was merged into predicate_pushdown upstream.
    if (isFALSE(collapse_joins)) {
      prop(optimizations, "predicate_pushdown", check = FALSE) <- FALSE
      need_validation <- TRUE
    }
  }

  if (is_present(no_optimization)) {
    warn_func("no_optimization")
    if (isTRUE(no_optimization)) {
      optimizations <- optimizations$no_optimizations()
    }
  }

  if (need_validation) {
    validate(optimizations)
  }

  optimizations
}
