#' Combine multiple DataFrames, LazyFrames, or Series into a single object
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> [DataFrames][DataFrame],
#' [LazyFrames], [Series]. All elements must have the same class.
#' @param how Strategy to concatenate items. Must be one of:
#' * `"vertical"`: applies multiple vstack operations;
#' * `"vertical_relaxed"`: same as `"vertical"`, but additionally coerces
#'   columns to their common supertype if they are mismatched (eg: Int32 to
#'   Int64);
#' * `"diagonal"`: finds a union between the column schemas and fills missing
#'   column values with `null`;
#' * `"diagonal_relaxed"`: same as `"diagonal"`, but additionally coerces
#'   columns to their common supertype if they are mismatched (eg: Int32 to
#'   Int64);
#' * `"horizontal"`: stacks Series from DataFrames horizontally and fills with
#'   `null` if the lengths don’t match;
#' * `"align"`: Combines frames horizontally, auto-determining the common key
#'   columns and aligning rows using the same logic as `align_frames`; this
#'   behaviour is patterned after a full outer join, but does not handle
#'   column-name collision. (If you need more control, you should use a
#'   suitable join method instead).
#'
#' [Series] only support the `"vertical"` strategy.
#' @param rechunk Make sure that the result data is in contiguous memory.
#' @param parallel Only relevant for [LazyFrames][LazyFrame]. This determines if the
#' concatenated lazy computations may be executed in parallel.
#'
#' @return The same class (`polars_data_frame`, `polars_lazy_frame` or
#' `polars_series`) as the input.
#' @examples
#' # default is 'vertical' strategy
#' df1 <- pl$DataFrame(a = 1L, b = 3L)
#' df2 <- pl$DataFrame(a = 2L, b = 4L)
#' pl$concat(df1, df2)
#'
#' # 'a' is coerced to float64
#' df1 <- pl$DataFrame(a = 1L, b = 3L)
#' df2 <- pl$DataFrame(a = 2, b = 4L)
#' pl$concat(df1, df2, how = "vertical_relaxed")
#'
#' df_h1 <- pl$DataFrame(l1 = 1:2, l2 = 3:4)
#' df_h2 <- pl$DataFrame(r1 = 5:6, r2 = 7:8, r3 = 9:10)
#' pl$concat(df_h1, df_h2, how = "horizontal")
#'
#' # use 'diagonal' strategy to fill empty column values with nulls
#' df1 <- pl$DataFrame(a = 1L, b = 3L)
#' df2 <- pl$DataFrame(a = 2L, c = 4L)
#' pl$concat(df1, df2, how = "diagonal")
#'
#' df_a1 <- pl$DataFrame(id = 1:2, x = 3:4)
#' df_a2 <- pl$DataFrame(id = 2:3, y = 5:6)
#' df_a3 <- pl$DataFrame(id = c(1L, 3L), z = 7:8)
#' pl$concat(df_a1, df_a2, df_a3, how = "align")
pl__concat <- function(
    ...,
    how = c(
      "vertical",
      "vertical_relaxed",
      "diagonal",
      "diagonal_relaxed",
      "horizontal",
      "align"
    ),
    rechunk = FALSE,
    parallel = TRUE) {
  check_dots_unnamed()
  dots <- list2(...)
  how <- arg_match0(
    how,
    values = c(
      "vertical",
      "vertical_relaxed",
      "diagonal",
      "diagonal_relaxed",
      "horizontal",
      "align"
    )
  )

  if (length(dots) == 0L) {
    abort("`...` must not be empty.")
  }

  first <- dots[[1]]

  if (length(dots) == 1 && (is_polars_df(first) || is_polars_series(first) || is_polars_lf(first))) {
    return(first)
  }

  all_df_lf_series <- all(vapply(dots, is_polars_df, FUN.VALUE = logical(1))) ||
    all(vapply(dots, is_polars_lf, FUN.VALUE = logical(1))) ||
    all(vapply(dots, is_polars_series, FUN.VALUE = logical(1)))
  if (!all_df_lf_series) {
    abort(
      "All elements in `...` must be of the same class (`polars_data_frame`, `polars_lazy_frame`, or `polars_series`)."
    )
  }

  if (how == "align") {
    if (!is_polars_df(first) && !is_polars_lf(first)) {
      abort(r"("align" strategy is only supported on DataFrames and LazyFrames.)")
    }

    all_columns <- lapply(dots, \(x) names(x))
    common_cols <- Reduce(intersect, all_columns)
    if (length(common_cols) == 0) {
      abort("'align' strategy requires at least one common column.")
    }

    # align the frame data using a full outer join with no suffix-resolution
    # (so we raise an error in case of column collision, like "horizontal")
    lfs <- lapply(dots, as_polars_lf)
    # TODO: requires <lazyframe>$join
    abort("TODO")
    lf <- Reduce(
      x = lfs,
      \(x, y) {
        x$join(
          y,
          how = "full", on = common_cols, suffix = "_PL_CONCAT_RIGHT"
        )$with_columns(
          !!!lapply(common_cols, \(col) pl$coalesce(pl$col(col), pl$col(paste0(col, "_PL_CONCAT_RIGHT"))))
        )$drop(paste0(common_cols, "_PL_CONCAT_RIGHT"))
      },
      accumulate = TRUE
    )$sort(common_cols)

    if (is_polars_df(first)) {
      out <- lf$collect()
    } else {
      out <- lf
    }
    return(out)
  }

  if (is_polars_df(first)) {
    out <- switch(how,
      vertical = {
        dots |>
          lapply(\(x) x$`_df`) |>
          concat_df() |>
          wrap()
      },
      vertical_relaxed = {
        (
          dots |>
            lapply(\(x) x$lazy()$`_ldf`) |>
            concat_lf(
              rechunk = rechunk,
              parallel = parallel,
              to_supertypes = TRUE
            ) |>
            wrap()
        )$collect(no_optimization = TRUE)
      },
      diagonal = {
        dots |>
          lapply(\(x) x$`_df`) |>
          concat_df_diagonal() |>
          wrap()
      },
      diagonal_relaxed = {
        (
          dots |>
            lapply(\(x) x$lazy()$`_ldf`) |>
            concat_lf_diagonal(
              rechunk = rechunk,
              parallel = parallel,
              to_supertypes = TRUE
            ) |>
            wrap()
        )$collect(no_optimization = TRUE)
      },
      horizontal = {
        dots |>
          lapply(\(x) x$`_df`) |>
          concat_df_horizontal() |>
          wrap()
      },
      abort("Unreachable")
    )
  } else if (is_polars_lf(first)) {
    out <- switch(how,
      vertical = ,
      vertical_relaxed = {
        dots |>
          lapply(\(x) x$`_ldf`) |>
          concat_lf(
            rechunk = rechunk,
            parallel = parallel,
            to_supertypes = endsWith(how, "relaxed")
          )
      },
      diagonal = ,
      diagonal_relaxed = {
        dots |>
          lapply(\(x) x$`_ldf`) |>
          concat_lf_diagonal(
            rechunk = rechunk,
            parallel = parallel,
            to_supertypes = endsWith(how, "relaxed")
          )
      },
      horizontal = {
        dots |>
          lapply(\(x) x$`_ldf`) |>
          concat_lf_horizontal(parallel = parallel)
      },
      abort("Unreachable")
    ) |>
      wrap()
  } else if (is_polars_series(first)) {
    out <- switch(how,
      vertical = {
        dots |>
          lapply(\(x) x$`_s`) |>
          concat_series() |>
          wrap()
      },
      abort("Series only supports 'vertical' concat strategy.")
    )
  } else {
    abort("Unreachable")
  }

  if (isTRUE(rechunk)) {
    out$rechunk()
  } else {
    out
  }
}
