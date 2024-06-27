pl__all <- function(names = NULL, ignore_nulls = TRUE) {
  if (is.null(names)) {
    pl$col("*")
  } else {
    pl$col(names)$all(ignore_nulls = ignore_nulls)
  }
}

pl__any <- function(names, ignore_nulls = TRUE) {
  pl$col(names)$any(ignore_nulls = ignore_nulls)
}
