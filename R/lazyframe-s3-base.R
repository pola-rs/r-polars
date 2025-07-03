#' @export
dim.polars_lazy_frame <- function(x) c(NA_integer_, length(x$collect_schema()))

#' @export
length.polars_lazy_frame <- function(x) length(x$collect_schema())

#' @export
names.polars_lazy_frame <- function(x) names(x$collect_schema())

#' @export
#' @rdname s3-as.list
as.list.polars_lazy_frame <- as.list.polars_data_frame

#' @export
#' @rdname s3-as.data.frame
as.data.frame.polars_lazy_frame <- as.data.frame.polars_data_frame

#' @exportS3Method utils::head
head.polars_lazy_frame <- head.polars_data_frame

#' @exportS3Method utils::tail
tail.polars_lazy_frame <- tail.polars_data_frame


# Try to match `tibble` behavior as much as possible, following
# https://tibble.tidyverse.org/articles/invariants.html#column-subsetting
# TODO: add document
#' @export
`[.polars_lazy_frame` <- function(x, i, j, ..., drop = FALSE) {
  # get from `[.polars_data_frame`
  i_arg <- substitute(i)
  j_arg <- substitute(j) # nolint: object_usage_linter

  if (isTRUE(drop)) {
    warn(c(`!` = "`drop = TRUE` is not supported for LazyFrame."))
  }
  if (!missing(i)) {
    n_real_args <- nargs() - !missing(drop)
    if (n_real_args > 2) {
      # We want to allow lf[TRUE, ], lf[FALSE, ] and lf[NULL, ].
      if (is_null(i) || (is_bare_logical(i) && isFALSE(i))) {
        x <- x$clear()
      } else if (!is_bare_logical(i) || !isTRUE(i)) {
        abort(
          c(
            `!` = "Cannot subset rows of a LazyFrame with `[`.",
            i = "There are several functions that can be used to get a specific rows.",
            `*` = "`$slice()` can be used to get a slice of rows with start index and length.",
            `*` = "`$gather_every()` can be used to take every nth row.",
            `*` = "`$filter()` can be used to filter rows based on a condition.",
            `*` = "`$reverse()` can be used to reverse the order of rows."
          )
        )
      }
    } else {
      j <- i
      j_arg <- i_arg
    }
  }

  `[.polars_data_frame`(x, TRUE, j, drop = FALSE)
}
