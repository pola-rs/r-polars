#' Return the number of threads in the Polars thread pool
#'
#' @details
#' The threadpool size can be overridden by setting the
#' `POLARS_MAX_THREADS` environment variable before process start.
#' It cannot be modified once the package is loaded.
#' It is strongly recommended not to override this value as it will be
#' set automatically by the engine.
#' @return The integer of threads used by polars engine.
#' @seealso
#' - [polars_info()] shows the thread pool size and other information.
#' @examples
#' pl$thread_pool_size()
pl__thread_pool_size <- thread_pool_size
