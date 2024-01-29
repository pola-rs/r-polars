#' Get polars environment variables
#'
#' @details The following envvars are available (in alphabetical order, with the
#'   default value in parenthesis):
#'
#' * `POLARS_FMT_MAX_COLS` (`5`): Set the number of columns that are visible when
#'   displaying tables. If negative, all columns are displayed.
#' * `POLARS_FMT_MAX_ROWS` (`8`): Set the number of rows that are visible when
#'   displaying tables. If negative, all rows are displayed. This applies to both
#'   [`DataFrame`][DataFrame_class] and [`Series`][Series_class].
#' * `POLARS_FMT_STR_LEN` (`32`): Maximum number of characters to display;
#' * `POLARS_FMT_TABLE_CELL_ALIGNMENT` (`"LEFT"`): set the table cell alignment.
#'   Can be `"LEFT"`, `"CENTER"`, `"RIGHT"`;
#' * `POLARS_FMT_TABLE_CELL_LIST_LEN` (`3`): Maximum number of elements of list
#'   variables to display;
#' * `POLARS_FMT_TABLE_CELL_NUMERIC_ALIGNMENT` (`"LEFT"`): Set the table cell
#'   alignment for numeric columns. Can be `"LEFT"`, `"CENTER"`, `"RIGHT"`;
#' * `POLARS_FMT_TABLE_DATAFRAME_SHAPE_BELOW` (`"0"`): print the DataFrame shape
#'   information below the data when displaying tables. Can be `"0"` or `"1"`.
#' * `POLARS_FMT_TABLE_FORMATTING` (`"UTF8_FULL_CONDENSED"`): Set table
#'   formatting style. Possible values:
#'    * `"ASCII_FULL"`: ASCII, with all borders and lines, including row dividers.
#'    * `"ASCII_FULL_CONDENSED"`: Same as ASCII_FULL, but with dense row spacing.
#'    * `"ASCII_NO_BORDERS"`: ASCII, no borders.
#'    * `"ASCII_BORDERS_ONLY"`: ASCII, borders only.
#'    * `"ASCII_BORDERS_ONLY_CONDENSED"`: ASCII, borders only, dense row spacing.
#'    * `"ASCII_HORIZONTAL_ONLY"`: ASCII, horizontal lines only.
#'    * `"ASCII_MARKDOWN"`: ASCII, Markdown compatible.
#'    * `"UTF8_FULL"`: UTF8, with all borders and lines, including row dividers.
#'    * `"UTF8_FULL_CONDENSED"`: Same as UTF8_FULL, but with dense row spacing.
#'    * `"UTF8_NO_BORDERS"`: UTF8, no borders.
#'    * `"UTF8_BORDERS_ONLY"`: UTF8, borders only.
#'    * `"UTF8_HORIZONTAL_ONLY"`: UTF8, horizontal lines only.
#'    * `"NOTHING"`: No borders or other lines.
#' * `POLARS_FMT_TABLE_HIDE_COLUMN_DATA_TYPES` (`"0"`): Hide table column data
#'   types (i64, f64, str etc.). Can be `"0"` or `"1"`.
#' * `POLARS_FMT_TABLE_HIDE_COLUMN_NAMES` (`"0"`): Hide table column names. Can
#'   be `"0"` or `"1"`.
#' * `POLARS_FMT_TABLE_HIDE_COLUMN_SEPARATOR` (`"0"`): Hide the `"---"` separator
#'    between the column names and column types. Can be `"0"` or `"1"`.
#' * `POLARS_FMT_TABLE_HIDE_DATAFRAME_SHAPE_INFORMATION` (`"0"`): Hide the
#'   DataFrame shape information when displaying tables. Can be `"0"` or `"1"`.
#' * `POLARS_FMT_TABLE_INLINE_COLUMN_DATA_TYPE` (`"0"`): Moves the data type
#'   inline with the column name (to the right, in parentheses). Can be `"0"`
#'   or `"1"`.
#' * `POLARS_FMT_TABLE_ROUNDED_CORNERS` (`"0"`): Apply rounded corners to
#'   UTF8-styled tables (only applies to UTF8 formats).
#' * `POLARS_MAX_THREADS` (`<variable>`): Maximum number of threads used to
#'   initialize the thread pool. The thread pool is locked once polars is loaded,
#'   so this envvar must be set before loading the package.
#' * `POLARS_STREAMING_CHUNK_SIZE` (`<variable>`): Chunk size used in the
#'   streaming engine. Integer larger than 1. By default, the chunk size is
#'   determined by the schema and size of the thread pool. For some datasets
#'   (esp. when you have large string elements) this can be too optimistic and
#'   lead to Out of Memory errors.
#' * `POLARS_TABLE_WIDTH` (`<variable>`): Set the maximum width of a table in
#'   characters.
#' * `POLARS_VERBOSE` (`"0"`): Enable additional verbose/debug logging.
#' * `POLARS_WARN_UNSTABLE` (`"0"`): Issue a warning when unstable functionality
#'    is used. Enabling this setting may help avoid functionality that is still
#'    evolving, potentially reducing maintenance burden from API changes and bugs.
#'    Can be `"0"` or `"1"`.
#'
# See https://github.com/pola-rs/polars/blob/6913b16c255f38c8609ea11f1b2edab6482cedc5/py-polars/polars/config.py#L73
#' The following configuration options are present in the Python API but
#' currently cannot be changed in R: decimal separator, thousands separator,
#' float precision, float formatting, trimming decimal zeros.
#'
#' @return `polars_envvars()` returns a named list where the names are the names
#'   of environment variables and values are their values.
#'
#' @export
#' @examples
#' polars_envvars()
#'
#' pl$DataFrame(x = "This is a very very very long sentence.")
#'
#' Sys.setenv(POLARS_FMT_STR_LEN = 50)
#' pl$DataFrame(x = "This is a very very very long sentence.")
#'
#' # back to default
#' Sys.setenv(POLARS_FMT_STR_LEN = 32)
#'
polars_envvars = function() {
  envvars = rbind(
    # c("POLARS_AUTO_STRUCTIFY", ""),
    c("POLARS_FMT_MAX_COLS", "5"),
    c("POLARS_FMT_MAX_ROWS", "8"),
    # Exist in polars but can't be set (even in py-polars)
    # c("POLARS_FMT_NUM_DECIMAL", ""),
    # c("POLARS_FMT_NUM_GROUP_SEPARATOR", ""),
    # c("POLARS_FMT_NUM_LEN", ""),
    c("POLARS_FMT_STR_LEN", "32"),
    c("POLARS_FMT_TABLE_CELL_ALIGNMENT", "LEFT"),
    c("POLARS_FMT_TABLE_CELL_LIST_LEN", "3"),
    c("POLARS_FMT_TABLE_CELL_NUMERIC_ALIGNMENT", "LEFT"),
    c("POLARS_FMT_TABLE_DATAFRAME_SHAPE_BELOW", "0"),
    c("POLARS_FMT_TABLE_FORMATTING", "UTF8_FULL_CONDENSED"),
    c("POLARS_FMT_TABLE_HIDE_COLUMN_DATA_TYPES", "0"),
    c("POLARS_FMT_TABLE_HIDE_COLUMN_NAMES", "0"),
    c("POLARS_FMT_TABLE_HIDE_COLUMN_SEPARATOR", "0"),
    c("POLARS_FMT_TABLE_HIDE_DATAFRAME_SHAPE_INFORMATION", "0"),
    c("POLARS_FMT_TABLE_INLINE_COLUMN_DATA_TYPE", "0"),
    c("POLARS_FMT_TABLE_ROUNDED_CORNERS", "0"),
    c("POLARS_MAX_THREADS", threadpool_size()),
    c("POLARS_STREAMING_CHUNK_SIZE", "variable"),
    c("POLARS_TABLE_WIDTH", "variable"),
    c("POLARS_VERBOSE", "0"),
    c("POLARS_WARN_UNSTABLE", "0")
  ) |> as.data.frame()
  out = vector("list", length(envvars))
  for (i in 1:nrow(envvars)) {
    e = envvars[[1]][i]
    out[[e]] = Sys.getenv(e, unset = envvars[[2]][i])
  }
  structure(out, class = "polars_envvars")
}

#' @noRd
#' @export
print.polars_envvars = function(x, ...) {
  # Copied from the arrow package
  # https://github.com/apache/arrow/blob/6f3bd2524c2abe3a4a278fc1c62fc5c49b56cab3/r/R/arrow-info.R#L149-L157
  print_key_values = function(title, vals, ...) {
    df = data.frame(vals, ...)
    names(df) = ""

    cat(title, ":\n========", sep = "")
    print(df)
    cat("\nSee `?polars::polars_envvars` for the definition of all envvars.")
  }

  print_key_values("Environment variables", unlist(x))
}
