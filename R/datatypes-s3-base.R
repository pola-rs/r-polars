# This method is not auto-generated in `generated-*` file,
# because it has a special case for the `union` method
#' @export
`$.polars_dtype_enum` <- function(x, name) {
  # Enum only method `union`
  if (identical(name, "union")) {
    fn <- function(other) {
      wrap({
        check_polars_dtype(other)
        if (!inherits(other, "polars_dtype_enum")) {
          abort("`other` must be a Enum data type")
        }

        PlRDataType$new_enum(unique(c(self$categories, other$categories)))
      })
    }
    self <- x
    environment(fn) <- environment()
    fn
  } else {
    NextMethod()
  }
}

# This method is not auto-generated in `generated-*` file,
# because it has a special case for the `union` method
#' @exportS3Method utils::.DollarNames
.DollarNames.polars_dtype_enum <- function(x, pattern = "") {
  member_names <- ls(x, all.names = TRUE)
  # Enum only method `union`
  method_names <- c("union", names(polars_datatype__methods))

  all_names <- union(member_names, method_names)
  filtered_names <- findMatches(pattern, all_names)

  filtered_names[!startsWith(filtered_names, "_")]
}

#' @export
print.polars_dtype <- function(x, ...) {
  format(x, abbreviated = FALSE) |>
    writeLines()
  invisible(x)
}

#' @param abbreviated If `TRUE`, use the abbreviated form of the dtype name,
#' e.g. "i64" instead of "Int64".
#' @export
#' @noRd
format.polars_dtype <- function(x, ..., abbreviated = FALSE) {
  check_dots_empty0(...)
  x$`_dt`$as_str(abbreviated = abbreviated)
}
