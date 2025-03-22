# The env for storing rolling_group_by methods
polars_sql_context__methods <- new.env(parent = emptyenv())

#' @export
wrap.PlRSQLContext <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_ctxt` <- x

  class(self) <- c("polars_sql_context", "polars_object")
  self
}

#' Initialize a new `SQLContext`
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Elements that are known in the
#' current `SQLContext`. It accepts any R object that can be converted to a
#' LazyFrame via `as_polars_lf()`. All elements must be named.
#'
# TODO: add this param (see commit that dropped incomplete implementation in
# https://github.com/eitsupi/neo-r-polars/pull/205)
# @param .register_globals Register compatible objects found in the global
# environment, automatically mapping their name to a table name. To register
# other objects, pass them explicitly in `...`, or call the `execute_global`
# class function.
#'
#' @return An object of class `"polars_sql_context"`
#' @examples
#' pl$SQLContext(mtcars = mtcars)
#'
#' pl$SQLContext(mtcars = mtcars, a = data.frame(x = 1))
pl__SQLContext <- function(...) {
  wrap({
    self <- PlRSQLContext$new() |>
      wrap()
    self$register_many(...)
    self
  })
}

#' Register a single frame as a table, using the given name
#'
#' @param name Name of the table.
#' @param frame Object to associate with this table name.
#'
#' @inherit pl__SQLContext return
#' @examples
#' df <- pl$DataFrame(x = 1)
#' ctx <- pl$SQLContext()
#' ctx$register("frame_data", df)$execute("SELECT * FROM frame_data")$collect()
sql_context__register <- function(name, frame = NULL) {
  wrap({
    frame <- as_polars_lf(frame)
    self$`_ctxt`$register(name, frame$`_ldf`)
    self
  })
}

#' Register multiple eager/lazy frames as tables, using the associated names
#'
#' @inherit pl__SQLContext params return
#' @examples
#' df <- pl$DataFrame(x = 1)
#' df2 <- pl$DataFrame(x = 2)
#' df3 <- pl$DataFrame(x = 3)
#'
#' ctx <- pl$SQLContext()
#' ctx$register_many(tab1 = df, tab2 = df2, tab3 = df3)
sql_context__register_many <- function(...) {
  wrap({
    frames <- list2(...)
    if (!is_named2(frames)) {
      abort("All frames in `...` must be named.", call = caller_env(3))
    }
    for (i in seq_along(frames)) {
      self$register(names(frames)[i], frames[[i]])
    }
    self
  })
}

#' Return a list of the registered table names
#'
#' @details
#' This method will return the same values as the "SHOW TABLES" SQL statement,
#' but as a vector instead of a frame.
#'
#' @return A character vector
#' @examples
#' # Executing as SQL:
#' frame_data <- pl$DataFrame(x = 1)
#' ctx <- pl$SQLContext(hello_world=frame_data, foo = data.frame(x = 2))
#' ctx$execute("SHOW TABLES")$collect()
#'
#' # Calling the method:
#' ctx$tables()
sql_context__tables <- function() {
  wrap({
    self$`_ctxt`$get_tables() |>
      sort()
  })
}

#' Parse the given SQL query and execute it against the registered frame data
#'
#' @param query A valid string SQL query.
#'
#' @inherit as_polars_lf return
#' @examples
#' # Declare frame data and register with a SQLContext:
#' df <- pl$DataFrame(
#'   title = c(
#'     "The Godfather",
#'     "The Dark Knight",
#'     "Schindler's List",
#'     "Pulp Fiction",
#'     "The Shawshank Redemption"
#'   ),
#'   release_year = c(1972, 2008, 1993, 1994, 1994),
#'   budget = c(6 * 1e6, 185 * 1e6, 22 * 1e6, 8 * 1e6, 25 * 1e6),
#'   gross = c(134821952, 533316061, 96067179, 107930000, 28341469),
#'   imdb_score = c(9.2, 9, 8.9, 8.9, 9.3)
#' )
#'
#' ctx <- pl$SQLContext(films = df)
#' ctx$execute(
#'   "
#'      SELECT title, release_year, imdb_score
#'      FROM films
#'      WHERE release_year > 1990
#'      ORDER BY imdb_score DESC
#'      "
#' )$collect()
#'
#' # Execute a GROUP BY query:
#' ctx$execute(
#'   "
#'   SELECT
#'        MAX(release_year / 10) * 10 AS decade,
#'        SUM(gross) AS total_gross,
#'        COUNT(title) AS n_films,
#'   FROM films
#'   GROUP BY (release_year / 10) -- decade
#'   ORDER BY total_gross DESC
#'   "
#' )$collect()
sql_context__execute <- function(query) {
  wrap({
    self$`_ctxt`$execute(query)
  })
}
