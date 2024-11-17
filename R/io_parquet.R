#' Scan a parquet file
#'
#' @inherit pl_scan_csv return
#' @inheritParams pl_scan_csv
#' @inheritParams pl_scan_ipc
#' @param source Path to a file. You can use globbing with `*` to scan/read multiple
#' files in the same directory (see examples).
#' @param cache Cache the result after reading.
#' @param parallel This determines the direction of parallelism. `"auto"` will
#' try to determine the optimal direction. Can be `"auto"`, `"columns"`,
#' `"row_groups"`, `"prefiltered"`, or `"none"`. See 'Details'.
#' @param rechunk In case of reading multiple files via a glob pattern, rechunk
#' the final DataFrame into contiguous memory chunks.
#' @param glob Expand path given via globbing rules.
#' @param schema Specify the datatypes of the columns. The datatypes must match the datatypes in the file(s).
#' If there are extra columns that are not in the file(s), consider also enabling `allow_missing_columns`.
#' @param use_statistics Use statistics in the parquet file to determine if pages
#' can be skipped from reading.
#' @param storage_options Experimental. List of options necessary to scan
#' parquet files from different cloud storage providers (GCP, AWS, Azure,
#' HuggingFace). See the 'Details' section.
#' @param allow_missing_columns When reading a list of parquet files, if a column existing in the first
#' file cannot be found in subsequent files, the default behavior is to raise an error.
#' However, if `allow_missing_columns` is set to `TRUE`, a full-NULL column is returned
#' instead of erroring for the files that do not contain the column.
#'
#' @rdname IO_scan_parquet
#' @details
#' ## On parallel strategies
#'
#' The prefiltered strategy first evaluates the pushed-down predicates in
#' parallel and determines a mask of which rows to read. Then, it parallelizes
#' over both the columns and the row groups while filtering out rows that do not
#' need to be read. This can provide significant speedups for large files (i.e.
#' many row-groups) with a predicate that filters clustered rows or filters
#' heavily. In other cases, prefiltered may slow down the scan compared other
#' strategies.
#'
#' The prefiltered settings falls back to auto if no predicate is given.
#'
#'
#' ## Connecting to cloud providers
#'
#' Polars supports scanning parquet files from different cloud providers.
#' The cloud providers currently supported are AWS, GCP, and Azure.
#' The supported keys to pass to the `storage_options` argument can be found
#' here:
#'
#' - [aws](https://docs.rs/object_store/latest/object_store/aws/enum.AmazonS3ConfigKey.html)
#' - [gcp](https://docs.rs/object_store/latest/object_store/gcp/enum.GoogleConfigKey.html)
#' - [azure](https://docs.rs/object_store/latest/object_store/azure/enum.AzureConfigKey.html)
#'
#' Currently it is impossible to scan public parquet files from GCP without
#' a valid service account. Be sure to always include a service account in the
#' `storage_options` argument.
#'
#' ## Scanning from HuggingFace
#'
#' It is possible to scan data stored on HuggingFace using a path starting with
#' `hf://`. The `hf://` path format is defined as
#' `hf://BUCKET/REPOSITORY@REVISION/PATH`, where:
#'
#' * BUCKET is one of datasets or spaces
#' * REPOSITORY is the location of the repository. this is usually in the
#'   format of username/repo_name. A branch can also be optionally specified by
#'   appending `@branch`.
#' * REVISION is the name of the branch (or commit) to use. This is optional
#'   and defaults to main if not given.
#' * PATH is a file or directory path, or a glob pattern from the repository
#'   root.
#'
#' A Hugging Face API key can be passed to access private locations using
#' either of the following methods:
#' * Passing a token in storage_options to the scan function, e.g.
#'   `scan_parquet(..., storage_options = list(token = <your HF token>))`
#' * Setting the HF_TOKEN environment variable, e.g.
#'   `Sys.setenv(HF_TOKEN = <your HF token>)`.
#'
#' @examplesIf requireNamespace("withr", quietly = TRUE)
#' # Write a Parquet file than we can then import as DataFrame
#' temp_file = withr::local_tempfile(fileext = ".parquet")
#' as_polars_df(mtcars)$write_parquet(temp_file)
#'
#' pl$scan_parquet(temp_file)$collect()
#'
#' # Write a hive-style partitioned parquet dataset
#' temp_dir = withr::local_tempdir()
#' as_polars_df(mtcars)$write_parquet(temp_dir, partition_by = c("cyl", "gear"))
#' list.files(temp_dir, recursive = TRUE)
#'
#' # If the path is a folder, Polars automatically tries to detect partitions
#' # and includes them in the output
#' pl$scan_parquet(temp_dir)$collect()
pl_scan_parquet = function(
    source,
    ...,
    n_rows = NULL,
    row_index_name = NULL,
    row_index_offset = 0L,
    parallel = c(
      "auto",
      "columns",
      "row_groups",
      "none"
    ),
    hive_partitioning = NULL,
    hive_schema = NULL,
    try_parse_hive_dates = TRUE,
    glob = TRUE,
    schema = NULL,
    rechunk = FALSE,
    low_memory = FALSE,
    storage_options = NULL,
    use_statistics = TRUE,
    cache = TRUE,
    include_file_paths = NULL,
    allow_missing_columns = FALSE) {
  new_from_parquet(
    path = source,
    n_rows = n_rows,
    cache = cache,
    parallel = parallel,
    rechunk = rechunk,
    row_name = row_index_name,
    row_index = row_index_offset,
    low_memory = low_memory,
    use_statistics = use_statistics,
    hive_partitioning = hive_partitioning,
    hive_schema = hive_schema,
    try_parse_hive_dates = try_parse_hive_dates,
    storage_options = storage_options,
    glob = glob,
    schema = schema,
    include_file_paths = include_file_paths,
    allow_missing_columns = allow_missing_columns
  ) |>
    unwrap("in pl$scan_parquet():")
}

#' Read a parquet file
#' @rdname IO_read_parquet
#' @inherit pl_read_csv return
#' @inherit pl_scan_parquet params details
#' @examplesIf requireNamespace("withr", quietly = TRUE)
#' # Write a Parquet file than we can then import as DataFrame
#' temp_file = withr::local_tempfile(fileext = ".parquet")
#' as_polars_df(mtcars)$write_parquet(temp_file)
#'
#' pl$read_parquet(temp_file)
#'
#' # Write a hive-style partitioned parquet dataset
#' temp_dir = withr::local_tempdir()
#' as_polars_df(mtcars)$write_parquet(temp_dir, partition_by = c("cyl", "gear"))
#' list.files(temp_dir, recursive = TRUE)
#'
#' # If the path is a folder, Polars automatically tries to detect partitions
#' # and includes them in the output
#' pl$read_parquet(temp_dir)
pl_read_parquet = function(
    source,
    ...,
    n_rows = NULL,
    row_index_name = NULL,
    row_index_offset = 0L,
    parallel = c(
      "auto",
      "columns",
      "row_groups",
      "none"
    ),
    hive_partitioning = NULL,
    hive_schema = NULL,
    try_parse_hive_dates = TRUE,
    glob = TRUE,
    schema = NULL,
    rechunk = TRUE,
    low_memory = FALSE,
    storage_options = NULL,
    use_statistics = TRUE,
    cache = TRUE,
    include_file_paths = NULL,
    allow_missing_columns = FALSE) {
  .args = as.list(environment())
  result({
    do.call(pl$scan_parquet, .args)$collect()
  }) |>
    unwrap("in pl$read_parquet():")
}
