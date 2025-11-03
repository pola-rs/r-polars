# The env for storing QueryOptFlags methods
polars_query_opt_flags__methods <- new.env(parent = emptyenv())

QueryOptFlags <- new_class(
  "QueryOptFlags",
  properties = list(
    # TODO: switch to scalar properties when supported
    # https://github.com/RConsortium/S7/pull/433
    type_coercion = class_logical,
    type_check = class_logical,
    predicate_pushdown = class_logical,
    projection_pushdown = class_logical,
    simplify_expression = class_logical,
    slice_pushdown = class_logical,
    comm_subplan_elim = class_logical,
    comm_subexpr_elim = class_logical,
    cluster_with_columns = class_logical,
    check_order_observe = class_logical,
    fast_projection = class_logical,
    eager = class_logical,
    streaming = class_logical
  ),
  constructor = function(
    ...,
    predicate_pushdown = TRUE,
    projection_pushdown = TRUE,
    simplify_expression = TRUE,
    slice_pushdown = TRUE,
    comm_subplan_elim = TRUE,
    comm_subexpr_elim = TRUE,
    cluster_with_columns = TRUE,
    check_order_observe = TRUE,
    fast_projection = TRUE
  ) {
    check_dots_empty0(...)

    # Should be synced with impl Default for OptFlags in Rust
    # https://github.com/pola-rs/polars/blob/d0be4c06447f2e530c6f68d3cd73b43f2e33e2f3/crates/polars-plan/src/frame/opt_state.rs#L77-L81 # nolint: line_length_linter
    new_object(
      S7_object(),
      type_coercion = TRUE,
      type_check = TRUE,
      predicate_pushdown = predicate_pushdown,
      projection_pushdown = projection_pushdown,
      simplify_expression = simplify_expression,
      slice_pushdown = slice_pushdown,
      comm_subplan_elim = comm_subplan_elim,
      comm_subexpr_elim = comm_subexpr_elim,
      cluster_with_columns = cluster_with_columns,
      check_order_observe = check_order_observe,
      fast_projection = fast_projection,
      eager = FALSE,
      streaming = FALSE
    )
  },
  validator = function(self) {
    call <- caller_env(4L)

    check_bool(self@type_coercion, arg = "type_coercion", call = call)
    check_bool(self@type_check, arg = "type_check", call = call)

    check_bool(self@predicate_pushdown, arg = "predicate_pushdown", call = call)
    check_bool(self@projection_pushdown, arg = "projection_pushdown", call = call)
    check_bool(self@simplify_expression, arg = "simplify_expression", call = call)
    check_bool(self@slice_pushdown, arg = "slice_pushdown", call = call)
    check_bool(self@comm_subplan_elim, arg = "comm_subplan_elim", call = call)
    check_bool(self@comm_subexpr_elim, arg = "comm_subexpr_elim", call = call)
    check_bool(self@cluster_with_columns, arg = "cluster_with_columns", call = call)
    check_bool(self@check_order_observe, arg = "check_order_observe", call = call)
    check_bool(self@fast_projection, arg = "fast_projection", call = call)

    check_bool(self@eager, arg = "eager", call = call)
    check_bool(self@streaming, arg = "streaming", call = call)
  }
)

pl__QueryOptFlags <- QueryOptFlags

# TODO: moved to generated file
# `local({})` is needed for `$` methods.
# https://github.com/RConsortium/S7/issues/390
local({
  method(`$`, QueryOptFlags) <- function(self, name) {
    method_names <- names(polars_query_opt_flags__methods)

    if (name %in% method_names) {
      fn <- polars_query_opt_flags__methods[[name]]
      environment(fn) <- environment()
      fn
    } else {
      # TODO: use abstract class and better handling
      prop(self, name) |>
        wrap()
    }
  }
})

#' @exportS3Method utils::.DollarNames
`.DollarNames.polars::QueryOptFlags` <- function(x, pattern = "") {
  property_names <- prop_names(x)
  method_names <- names(polars_query_opt_flags__methods)

  all_names <- c(property_names, method_names)
  filtered_names <- findMatches(pattern, all_names)

  filtered_names[!startsWith(filtered_names, "_")]
}

# TODO: This should be a constructor
# https://github.com/RConsortium/S7/issues/522
eager_opt_flags <- function() {
  QueryOptFlags()$no_optimizations() |>
    set_props(
      eager = TRUE,
      simplify_expression = TRUE
    )
}

# Because of immutability, unlike Python Polars, there are no side effects,
# and a new modified OptFlags is returned
QueryOptFlags__no_optimizations <- function() {
  set_props(
    self,
    predicate_pushdown = FALSE,
    projection_pushdown = FALSE,
    simplify_expression = FALSE,
    slice_pushdown = FALSE,
    comm_subplan_elim = FALSE,
    comm_subexpr_elim = FALSE,
    cluster_with_columns = FALSE,
    check_order_observe = FALSE,
    fast_projection = FALSE
  )
}
