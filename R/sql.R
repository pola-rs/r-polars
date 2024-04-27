#' Run SQL queries against DataFrame/LazyFrame data.
#'
#' Run SQL queries against [DataFrame][DataFrame_class]/[LazyFrame][LazyFrame_class] data.
#' @name SQLContext_class
#' @aliases RPolarsSQLContext
#' @examplesIf polars_info()$features$sql
#' lf = pl$LazyFrame(a = 1:3, b = c("x", NA, "z"))
#'
#' res = pl$SQLContext(frame = lf)$execute(
#'   "SELECT b, a*2 AS two_a FROM frame WHERE b IS NOT NULL"
#' )
#' res$collect()
NULL

#' @export
#' @noRd
.DollarNames.RPolarsSQLContext = function(x, pattern = "") {
  get_method_usages(RPolarsSQLContext, pattern = pattern)
}

#' @noRd
#' @export
print.RPolarsSQLContext = function(x, ...) {
  cat("RPolarsSQLContext\n")
  cat("  tables:", x$tables(), "\n")

  invisible(x)
}


#' Initialise a new SQLContext
#'
#' Create a new SQLContext and register the given LazyFrames.
#' @param ... Name-value pairs of [LazyFrame][LazyFrame_class] like objects to register.
#' @return An [SQLContext][SQLContext_class]
#' @examplesIf polars_info()$features$sql
#' ctx = pl$SQLContext(mtcars = mtcars)
#' ctx
pl_SQLContext = function(...) {
  check_feature("sql", "in $SQLContext()")

  self = .pr$SQLContext$new()
  lazyframes = list(...)

  if (length(lazyframes)) {
    for (index in seq_along(lazyframes)) {
      .pr$SQLContext$register(
        self,
        names(lazyframes[index]),
        lazyframes[[index]]
      ) |>
        unwrap("in $SQLContext()")
    }
  }

  self
}


#' Execute SQL query against the registered data
#'
#' Parse the given SQL query and execute it against the registered frame data.
#' @param query A valid string SQL query.
#' @return A [LazyFrame][LazyFrame_class]
#' @examplesIf polars_info()$features$sql
#' query = "SELECT * FROM mtcars WHERE cyl = 4"
#'
#' pl$SQLContext(mtcars = mtcars)$execute(query)
SQLContext_execute = function(query) {
  .pr$SQLContext$execute(self, query) |>
    unwrap("in $execute()")
}


#' Register a single data as a table
#'
#' Register a single frame as a table, using the given name.
#'
#' If a table with the same name is already registered, it will be overwritten.
#' @param name A string name to register the frame as.
#' @param frame A [LazyFrame][LazyFrame_class] like object to register.
#' @return Returns the [SQLContext][SQLContext_class] object invisibly.
#' @examplesIf polars_info()$features$sql
#' ctx = pl$SQLContext()
#' ctx$register("mtcars", mtcars)
#'
#' ctx$execute("SELECT * FROM mtcars LIMIT 5")$collect()
SQLContext_register = function(name, frame) {
  .pr$SQLContext$register(self, name, frame) |>
    unwrap("in $register()")
  invisible(self)
}


#' Register multiple data as tables
#'
#' Register multiple frames as tables.
#' @inherit SQLContext_register details return
#' @param ... Name-value pairs of [LazyFrame][LazyFrame_class] like objects to register.
#' @examplesIf polars_info()$features$sql
#' ctx = pl$SQLContext()
#' r_df = mtcars
#' pl_df = pl$DataFrame(mtcars)
#' pl_lf = pl$LazyFrame(mtcars)
#'
#' ctx$register_many(r_df = r_df, pl_df = pl_df, pl_lf = pl_lf)
#'
#' ctx$execute(
#'   "SELECT * FROM r_df
#'   UNION ALL
#'   SELECT * FROM pl_df
#'   UNION ALL
#'   SELECT * FROM pl_lf"
#' )$collect()
SQLContext_register_many = function(...) {
  lazyframes = list(...)

  if (length(lazyframes)) {
    for (index in seq_along(lazyframes)) {
      .pr$SQLContext$register(
        self,
        names(lazyframes[index]),
        lazyframes[[index]]
      ) |>
        unwrap("in $register_many()")
    }
  }

  invisible(self)
}


#' Unregister tables by name
#'
#' Unregister tables by name.
#' @inherit SQLContext_register return
#' @param names A character vector of table names to unregister.
#' @examplesIf polars_info()$features$sql
#' # Initialise a new SQLContext and register the given tables.
#' ctx = pl$SQLContext(x = mtcars, y = mtcars, z = mtcars)
#' ctx$tables()
#'
#' # Unregister some tables.
#' ctx$unregister(c("x", "y"))
#' ctx$tables()
SQLContext_unregister = function(names) {
  for (index in seq_along(names)) {
    .pr$SQLContext$unregister(self, names[index]) |>
      unwrap("in $register()")
  }
  invisible(self)
}


#' List registered tables
#'
#' Return a character vector of the registered table names.
#' @return A character vector of the registered table names.
#' @examplesIf polars_info()$features$sql
#' ctx = pl$SQLContext()
#' ctx$tables()
#' ctx$register("df1", mtcars)
#' ctx$tables()
#' ctx$register("df2", mtcars)
#' ctx$tables()
SQLContext_tables = function() {
  .pr$SQLContext$get_tables(self) |>
    unwrap("in $tables()")
}


#' Register all polars DataFrames/LazyFrames found in the environment
#'
#' Automatically maps variable names to table names.
#' @inherit SQLContext_register details return
#' @param ... Ignored.
#' @param envir The environment to search for polars DataFrames/LazyFrames.
#' @seealso
#' - [`<SQLContext>$register()`][SQLContext_register]
#' - [`<SQLContext>$register_many()`][SQLContext_register_many]
#' - [`<SQLContext>$unregister()`][SQLContext_unregister]
#' @examplesIf polars_info()$features$sql
#' df1 = pl$DataFrame(a = 1:3, b = c("x", NA, "z"))
#' df2 = pl$LazyFrame(a = 2:4, c = c("t", "w", "v"))
#'
#' # Register frames directly from variables found in the current environment.
#' ctx = pl$SQLContext()$register_globals()
#' ctx$tables()
#'
#' ctx$execute(
#'   "SELECT a, b, c FROM df1 LEFT JOIN df2 USING (a) ORDER BY a DESC"
#' )$collect()
SQLContext_register_globals = function(..., envir = parent.frame()) {
  Filter(
    \(x) inherits(get(x, envir = envir), c("RPolarsDataFrame", "RPolarsLazyFrame")),
    ls(envir = envir)
  ) |>
    sapply(\(x) get(x, envir = envir), simplify = FALSE, USE.NAMES = TRUE) |>
    do.call(self$register_many, args = _) |>
    result() |>
    unwrap("in $register_globals()")

  invisible(self)
}
