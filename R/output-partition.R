#' Partitioning scheme to write files
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Partitioning schemes are used to write multiple files with `sink_*` methods.
#'
#' - [`pl$PartitionByKey()`][polars_partitioning_scheme]: Split by the values of keys.
#'   The amount of files that can be written is not limited. However,
#'   when writing beyond a certain amount of files, the data for the remaining partitions
#'   is buffered before writing to the file.
#' - [`pl$PartitionMaxSize()`][polars_partitioning_scheme]: Split with a maximum size.
#'   If the size reaches the maximum size, it is closed and a new file is opened.
#' - [`pl$PartitionParted()`][polars_partitioning_scheme]: This is a specialized version of
#'   [`pl$PartitionByKey()`][polars_partitioning_scheme].
#'   Whereas [`pl$PartitionByKey()`][polars_partitioning_scheme] accepts data in any order,
#'   this scheme expects the input data to be pre-grouped or pre-sorted.
#'   This scheme suffers a lot less overhead, but may not be always applicable.
#'   Each new value of the key expressions starts a new partition,
#'   therefore repeating the same value multiple times may overwrite previous partitions.
#'
#' @inheritParams rlang::args_dots_empty
#' @param base_path The base path for the output files.
#'   Use the `mkdir` option of the `sink_*` methods to ensure directories
#'   in the path are created.
#' @param by Something can be coerced to a list of [expressions][polars_expr].
#'   Used to partition by.
#' @param include_key A bool indicating whether to include the key columns in the output files.
#' @param per_partition_sort_by Something can be coerced to a list of [expressions][polars_expr],
#'   or `NULL` (default). Used  to sort over within each partition.
#'   Note that this might increase the memory consumption needed for each partition.
#' @param max_size An integer-ish value indicating the maximum size in rows of
#'   each of the generated files.
#' @examplesIf requireNamespace("withr", quietly = TRUE)
#' # Partitioning by columns
#' temp_dir_1 <- withr::local_tempdir()
#' as_polars_lf(mtcars)$sink_parquet(
#'   pl$PartitionByKey(
#'     temp_dir_1,
#'     by = c("cyl", "am"),
#'     include_key = FALSE,
#'   ),
#'   mkdir = TRUE
#' )
#' list.files(temp_dir_1, recursive = TRUE)
#'
#' # Partitioning by max row size
#' temp_dir_2 <- withr::local_tempdir()
#' as_polars_lf(mtcars)$sink_csv(
#'   pl$PartitionMaxSize(
#'     temp_dir_2,
#'     max_size = 10,
#'   ),
#'   mkdir = TRUE
#' )
#'
#' files <- list.files(temp_dir_2, full.names = TRUE)
#' files
#' lapply(files, \(x) nrow(read.csv(x)))
#' @name polars_partitioning_scheme
NULL

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
