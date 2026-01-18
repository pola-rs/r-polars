#' Partitioning scheme to write files
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Partitioning schemes are used to write multiple files with `sink_*` methods.
#'
#' - [`pl$PartitionBy()`][polars_partitioning_scheme]: Configuration for writing to
#'   multiple output files. Supports partitioning by key expressions, file size limits,
#'   or both.
#'
#' The following functions are deprecated and will be removed in a future release:
#'
#' - `r lifecycle::badge("deprecated")` [`pl$PartitionByKey()`][polars_partitioning_scheme]:
#'   Use `pl$PartitionBy(key = ...)` instead.
#' - `r lifecycle::badge("deprecated")` [`pl$PartitionMaxSize()`][polars_partitioning_scheme]:
#'   Use `pl$PartitionBy(max_rows_per_file = ...)` instead.
#' - `r lifecycle::badge("deprecated")` [`pl$PartitionParted()`][polars_partitioning_scheme]:
#'   Use `pl$PartitionBy(key = ...)` with pre-sorted data instead.
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
#' @param by `r lifecycle::badge("deprecated")`
#'   Something can be coerced to a list of [expressions][polars_expr].
#'   Used to partition by. Use the `key` property of `pl$PartitionBy` instead.
#' @param per_partition_sort_by `r lifecycle::badge("deprecated")`
#'   Something can be coerced to a list of [expressions][polars_expr], or `NULL` (default).
#'   Used to sort over within each partition.
#'   Use the `per_partition_sort_by` property of `pl$PartitionBy` instead.
#' @param max_size `r lifecycle::badge("deprecated")`
#'   An integer-ish value indicating the maximum size in rows of each of the generated files.
#'   Use the `max_rows_per_file` property of `pl$PartitionBy` instead.
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

# New unified PartitionBy class (separate from SinkDirectory)
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
#' @param key Something can be coerced to a list of [expressions][polars_expr],
#'   or `NULL` (default). Expressions to partition by.
#' @param max_rows_per_file An integer-ish value indicating the maximum number of rows
#'   to write for each file. Note that files may have less than this amount of rows.
#' @param approximate_bytes_per_file An integer-ish value indicating the approximate
#'   number of bytes to write to each file. This is measured as the estimated size of
#'   the DataFrame in memory. If `NULL`, defaults to approximately 4GB when `key` is
#'   specified without `max_rows_per_file`; otherwise unlimited.
#' @order 0
pl__PartitionBy <- PartitionBy

# Legacy SinkDirectory class (for deprecated partition classes)
SinkDirectory <- new_class(
  "SinkDirectory",
  properties = list(
    base_path = prop_string(),
    partition_by = prop_list_of_rexpr(allow_null = TRUE, names = "none"),
    partition_keys_sorted = prop_bool(allow_null = TRUE),
    include_keys = prop_bool(allow_null = TRUE),
    per_partition_sort_by = prop_list_of_rexpr(allow_null = TRUE, names = "none"),
    per_file_sort_by = prop_list_of_rexpr(allow_null = TRUE, names = "none"),
    max_rows_per_file = prop_number_whole(allow_null = TRUE)
  ),
  constructor = function(
    base_path,
    ...,
    partition_by = NULL,
    partition_keys_sorted = NULL,
    include_keys = NULL,
    per_partition_sort_by = NULL,
    per_file_sort_by = NULL,
    max_rows_per_file = NULL
  ) {
    check_dots_empty0(...)

    new_object(
      S7_object(),
      base_path = base_path,
      partition_by = parse_to_rexpr_list(partition_by),
      partition_keys_sorted = partition_keys_sorted,
      include_keys = include_keys,
      per_partition_sort_by = parse_to_rexpr_list(per_partition_sort_by),
      per_file_sort_by = parse_to_rexpr_list(per_file_sort_by),
      max_rows_per_file = max_rows_per_file
    )
  }
)

PartitionMaxSize <- new_class(
  "PartitionMaxSize",
  parent = SinkDirectory,
  constructor = function(
    base_path,
    ...,
    max_size,
    per_partition_sort_by = NULL
  ) {
    check_dots_empty0(...)
    deprecate_warn(
      c(
        `!` = format_warning(sprintf(
          "%s is deprecated as of %s 1.8.0.",
          format_cls("PartitionMaxSize"),
          format_pkg("polars")
        )),
        i = format_warning(sprintf("Use %s instead.", format_cls("PartitionBy")))
      )
    )

    new_object(
      SinkDirectory(
        base_path = base_path,
        max_rows_per_file = max_size,
        per_partition_sort_by = per_partition_sort_by
      )
    )
  }
)

#' @rdname polars_partitioning_scheme
#' @aliases PartitionMaxSize
#' @order 2
pl__PartitionMaxSize <- PartitionMaxSize

PartitionByKey <- new_class(
  "PartitionByKey",
  parent = SinkDirectory,
  constructor = function(
    base_path,
    ...,
    by,
    include_key = TRUE,
    per_partition_sort_by = NULL
  ) {
    check_dots_empty0(...)
    deprecate_warn(
      c(
        `!` = format_warning(sprintf(
          "%s is deprecated as of %s 1.8.0.",
          format_cls("PartitionByKey"),
          format_pkg("polars")
        )),
        i = format_warning(sprintf("Use %s instead.", format_cls("PartitionBy")))
      )
    )

    new_object(
      SinkDirectory(
        base_path = base_path,
        partition_by = by,
        include_keys = include_key,
        per_partition_sort_by = per_partition_sort_by
      )
    )
  }
)

#' @rdname polars_partitioning_scheme
#' @aliases PartitionByKey
#' @order 1
pl__PartitionByKey <- PartitionByKey

PartitionParted <- new_class(
  "PartitionParted",
  parent = SinkDirectory,
  constructor = function(
    base_path,
    ...,
    by,
    include_key = TRUE,
    per_partition_sort_by = NULL
  ) {
    check_dots_empty0(...)
    deprecate_warn(
      c(
        `!` = format_warning(sprintf(
          "%s is deprecated as of %s 1.8.0.",
          format_cls("PartitionParted"),
          format_pkg("polars")
        )),
        i = format_warning(sprintf("Use %s instead.", format_cls("PartitionBy")))
      )
    )

    new_object(
      SinkDirectory(
        base_path = base_path,
        partition_by = by,
        partition_keys_sorted = TRUE,
        include_keys = include_key,
        per_partition_sort_by = per_partition_sort_by
      )
    )
  }
)

#' @rdname polars_partitioning_scheme
#' @aliases PartitionParted
#' @order 3
pl__PartitionParted <- PartitionParted
