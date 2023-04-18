.knit_file <- function(file_name) {
  file = file.path("files", file_name)
  output = tempfile(fileext = "md")
  on.exit(unlink(output))

  suppressWarnings(knitr::knit(file, output, quiet = TRUE, envir = new.env()))

  readLines(output) |>
    paste0(collapse = "\n") |>
    cat()
}

test_that("Snapshot test of knitr", {
  expect_snapshot(.knit_file("dataframe.Rmd"), cran = TRUE)
  withr::with_envvar(
    new = c("POLARS_FMT_TABLE_INLINE_COLUMN_DATA_TYPE" = "false"),
    expect_snapshot(.knit_file("dataframe.Rmd"), cran = TRUE)
  )
  withr::with_envvar(
    new = c("POLARS_FMT_TABLE_FORMATTING" = "DEFAULT"),
    expect_snapshot(.knit_file("dataframe.Rmd"), cran = TRUE)
  )
})
