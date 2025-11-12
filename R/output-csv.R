# Output CSV functions: sink_csv, write_csv

#' Evaluate the query in streaming mode and write to a CSV file
#'
#' @inherit lazyframe__sink_parquet description params return
#' @inheritParams rlang::args_dots_empty
#' @param include_bom Logical, whether to include UTF-8 BOM in the CSV output.
#' @param include_header Logical, whether to include header in the CSV output.
#' @param separator Separate CSV fields with this symbol.
#' @param line_terminator String used to end each row.
#' @param quote_char Byte to use as quoting character.
#' @param batch_size Number of rows that will be processed per thread.
#' @param datetime_format A format string, with the specifiers defined by the
#' [chrono](https://docs.rs/chrono/latest/chrono/format/strftime/index.html)
#' Rust crate. If no format specified, the default fractional-second precision
#' is inferred from the maximum timeunit found in the frame’s Datetime cols (if
#' any).
#' @param date_format A format string, with the specifiers defined by the
#' [chrono](https://docs.rs/chrono/latest/chrono/format/strftime/index.html)
#' Rust crate.
#' @param time_format A format string, with the specifiers defined by the
#' [chrono](https://docs.rs/chrono/latest/chrono/format/strftime/index.html)
#' Rust crate.
#' @param float_scientific Whether to use scientific form always (`TRUE`),
#' never (`FALSE`), or automatically (`NULL`) for Float32 and Float64 datatypes.
#' @param float_precision Number of decimal places to write, applied to both
#' Float32 and Float64 datatypes.
#' @param decimal_comma If `TRUE`, use a comma `","` as the decimal separator
#'   instead of a point. Floats will be encapsulated in quotes if necessary.
#' @param null_value A string representing null values (defaulting to the empty
#' string).
#' @param quote_style Determines the quoting strategy used. Must be one of:
#' * `"necessary"` (default): This puts quotes around fields only when
#'   necessary. They are necessary when fields contain a quote, delimiter or
#'   record terminator. Quotes are also necessary when writing an empty record
#'   (which is indistinguishable from a record with one empty field). This is
#'   the default.
#' * `"always"`: This puts quotes around every field. Always.
#' * `"never"`: This never puts quotes around fields, even if that results in
#'   invalid CSV data (e.g.: by not quoting strings containing the separator).
#' * `"non_numeric"`: This puts quotes around all fields that are non-numeric.
#'   Namely, when writing a field that does not parse as a valid float or
#'   integer, then quotes will be used even if they aren`t strictly necessary.
#'
#' @examples
#' # Sink table 'mtcars' from mem to CSV
#' tmpf <- tempfile(fileext = ".csv")
#' as_polars_lf(mtcars)$sink_csv(tmpf)
#'
#' # Create a query that can be run in streaming end-to-end
#' tmpf2 <- tempfile(fileext = ".csv")
#' lf <- pl$scan_csv(tmpf)$select(pl$col("cyl") * 2)$lazy_sink_csv(tmpf2)
#' lf$explain() |>
#'   cat()
#'
#' # Execute the query and write to disk
#' lf$collect()
#'
#' # Load CSV directly into a DataFrame / memory
#' pl$read_csv(tmpf2)
lazyframe__sink_csv <- function(
  path,
  ...,
  include_bom = FALSE,
  include_header = TRUE,
  separator = ",",
  line_terminator = "\n",
  quote_char = '"',
  batch_size = 1024,
  datetime_format = NULL,
  date_format = NULL,
  time_format = NULL,
  float_scientific = NULL,
  float_precision = NULL,
  decimal_comma = FALSE,
  null_value = "",
  quote_style = c("necessary", "always", "never", "non_numeric"),
  maintain_order = TRUE,
  storage_options = NULL,
  retries = 2,
  sync_on_close = c("none", "data", "all"),
  mkdir = FALSE,
  engine = c("auto", "in-memory", "streaming"),
  optimizations = QueryOptFlags()
) {
  wrap({
    check_dots_empty0(...)

    self$lazy_sink_csv(
      path = path,
      include_bom = include_bom,
      include_header = include_header,
      separator = separator,
      line_terminator = line_terminator,
      quote_char = quote_char,
      batch_size = batch_size,
      datetime_format = datetime_format,
      date_format = date_format,
      time_format = time_format,
      float_scientific = float_scientific,
      float_precision = float_precision,
      decimal_comma = decimal_comma,
      null_value = null_value,
      quote_style = quote_style,
      maintain_order = maintain_order,
      storage_options = storage_options,
      retries = retries,
      sync_on_close = sync_on_close,
      mkdir = mkdir
    )$collect(engine = engine, optimizations = optimizations)
  })

  invisible(NULL)
}

#' @rdname lazyframe__sink_csv
lazyframe__lazy_sink_csv <- function(
  path,
  ...,
  include_bom = FALSE,
  include_header = TRUE,
  separator = ",",
  line_terminator = "\n",
  quote_char = '"',
  batch_size = 1024,
  datetime_format = NULL,
  date_format = NULL,
  time_format = NULL,
  float_scientific = NULL,
  float_precision = NULL,
  decimal_comma = FALSE,
  null_value = "",
  quote_style = c("necessary", "always", "never", "non_numeric"),
  maintain_order = TRUE,
  storage_options = NULL,
  retries = 2,
  sync_on_close = c("none", "data", "all"),
  mkdir = FALSE
) {
  wrap({
    check_dots_empty0(...)

    target <- arg_to_sink_target(path)
    check_arg_is_1byte("separator", separator)
    check_arg_is_1byte("quote_char", quote_char)
    quote_style <- arg_match0(
      quote_style,
      values = c("necessary", "always", "never", "non_numeric")
    )
    sync_on_close <- arg_match0(
      sync_on_close %||% "none",
      values = c("none", "data", "all")
    )

    self$`_ldf`$sink_csv(
      target = target,
      include_bom = include_bom,
      include_header = include_header,
      separator = separator,
      line_terminator = line_terminator,
      quote_char = quote_char,
      batch_size = batch_size,
      datetime_format = datetime_format,
      date_format = date_format,
      time_format = time_format,
      float_scientific = float_scientific,
      float_precision = float_precision,
      decimal_comma = decimal_comma,
      null_value = null_value,
      quote_style = quote_style,
      maintain_order = maintain_order,
      sync_on_close = sync_on_close,
      mkdir = mkdir,
      storage_options = storage_options,
      retries = retries
    )
  })
}

#' Write to comma-separated values (CSV) file
#'
#' @inheritParams lazyframe__sink_csv
#' @param file File path to which the result will be written.
#'
#' @inherit dataframe__write_parquet return
#' @examples
#' tmpf <- tempfile()
#' as_polars_df(mtcars)$write_csv(tmpf)
#' pl$read_csv(tmpf)
#'
#' as_polars_df(mtcars)$write_csv(tmpf, separator = "|")
#' pl$read_csv(tmpf, separator = "|")
dataframe__write_csv <- function(
  file,
  ...,
  include_bom = FALSE,
  include_header = TRUE,
  separator = ",",
  line_terminator = "\n",
  quote_char = '"',
  batch_size = 1024,
  datetime_format = NULL,
  date_format = NULL,
  time_format = NULL,
  float_scientific = NULL,
  float_precision = NULL,
  decimal_comma = FALSE,
  null_value = "",
  quote_style = c("necessary", "always", "never", "non_numeric"),
  storage_options = NULL,
  retries = 2
) {
  wrap({
    check_dots_empty0(...)

    self$lazy()$sink_csv(
      path = file,
      include_bom = include_bom,
      include_header = include_header,
      separator = separator,
      line_terminator = line_terminator,
      quote_char = quote_char,
      batch_size = batch_size,
      datetime_format = datetime_format,
      date_format = date_format,
      time_format = time_format,
      float_scientific = float_scientific,
      float_precision = float_precision,
      decimal_comma = decimal_comma,
      null_value = null_value,
      quote_style = quote_style,
      storage_options = storage_options,
      retries = retries,
      optimizations = DEFAULT_EAGER_OPT_FLAGS,
      engine = "in-memory"
    )
  })
  invisible(NULL)
}
