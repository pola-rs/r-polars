#' Partitioning scheme to write files
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Partitioning schemes are used to write multiple files with `sink_*` and
#' `write_*` methods.
#'
#' - [`pl$PartitionBy()`][polars_partitioning_scheme]: Configuration for writing to
#'   multiple output files. Supports partitioning by key expressions, file size limits,
#'   or both.
#'
#' @inheritParams rlang::args_dots_empty
#' @param base_path The base path for the output files.
#'   Use the `mkdir` option of the `sink_*` methods to ensure directories
#'   in the path are created.
#' @param key
#'   Something can be coerced to a list of [expressions][polars_expr], or `NULL` (default).
#'   Used to partition by.
#' @param include_key
#'   A bool indicating whether to include the key columns in the output files.
#'   Can only be used if `key` is specified, otherwise should be `NULL`.
#' @param max_rows_per_file
#'   An integer-ish value indicating the maximum size in rows of each of the generated files.
#' @param approximate_bytes_per_file
#'   An integer-ish value indicating approximate number of bytes to write to each file, or `NULL`.
#'   This is measured as the estimated size of the DataFrame in memory.
#'   Defaults to approximately 4GB when `key` is specified without `max_rows_per_file`;
#'   otherwise unlimited.
#' @examplesIf requireNamespace("withr", quietly = TRUE)
#' # Partitioning by columns
#' temp_dir_1 <- withr::local_tempdir()
#' as_polars_lf(mtcars)$sink_parquet(
#'   pl$PartitionBy(
#'     temp_dir_1,
#'     key = c("cyl", "am"),
#'     include_key = FALSE
#'   ),
#'   mkdir = TRUE
#' )
#' list.files(temp_dir_1, recursive = TRUE)
#'
#' # Partitioning by max row size
#' temp_dir_2 <- withr::local_tempdir()
#' as_polars_lf(mtcars)$sink_csv(
#'   pl$PartitionBy(
#'     temp_dir_2,
#'     max_rows_per_file = 10
#'   ),
#'   mkdir = TRUE
#' )
#'
#' files <- list.files(temp_dir_2, full.names = TRUE)
#' files
#' lapply(files, \(x) nrow(read.csv(x)))
#'
#' # Partitioning by both key and size
#' temp_dir_3 <- withr::local_tempdir()
#' as_polars_lf(mtcars)$sink_parquet(
#'   pl$PartitionBy(
#'     temp_dir_3,
#'     key = "cyl",
#'     max_rows_per_file = 5,
#'     approximate_bytes_per_file = 1000000
#'   ),
#'   mkdir = TRUE
#' )
#' list.files(temp_dir_3, recursive = TRUE)
#' @name polars_partitioning_scheme
NULL

# Unified partitioning configuration for file sinks.
PartitionBy <- new_class(
  "PartitionBy",
  properties = list(
    base_path = prop_string(),
    key = prop_list_of_rexpr(allow_null = TRUE, names = "none"),
    include_key = prop_bool(allow_null = TRUE),
    max_rows_per_file = prop_number_whole(allow_null = TRUE),
    approximate_bytes_per_file = prop_number_whole(allow_null = TRUE)
  ),

  constructor = function(
    base_path,
    ...,
    key = NULL,
    include_key = NULL,
    max_rows_per_file = NULL,
    approximate_bytes_per_file = NULL
  ) {
    check_dots_empty0(...)

    if (is.null(key) && is.null(max_rows_per_file) && is.null(approximate_bytes_per_file)) {
      abort(
        sprintf(
          "at least one of (%s, %s, %s) must be specified.",
          format_arg("key"),
          format_arg("max_rows_per_file"),
          format_arg("approximate_bytes_per_file")
        )
      )
    }

    if (is.null(key) && !is.null(include_key)) {
      abort(
        sprintf(
          "%s cannot be used without specifying %s.",
          format_arg("include_key"),
          format_arg("key")
        )
      )
    }

    # Default approximate_bytes_per_file to ~4GB only when:
    # - key is specified AND max_rows_per_file is not specified
    # Otherwise, leave it NULL (Rust side will use u64::MAX = unlimited)
    if (is.null(approximate_bytes_per_file) && !is.null(key) && is.null(max_rows_per_file)) {
      approximate_bytes_per_file <- 4294967295
    }

    new_object(
      S7_object(),
      base_path = base_path,
      key = parse_to_rexpr_list(key),
      include_key = include_key,
      max_rows_per_file = max_rows_per_file,
      approximate_bytes_per_file = approximate_bytes_per_file
    )
  }
)

#' @rdname polars_partitioning_scheme
#' @aliases PartitionBy
#' @order 0
pl__PartitionBy <- PartitionBy
