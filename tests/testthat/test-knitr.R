.knit_file <- function(file_name, use = "knitr") {
  file = file.path("files", file_name)
  output = tempfile(fileext = ".md")
  on.exit(unlink(output))

  if (use == "rmarkdown") {
    suppressWarnings(rmarkdown::render(file, output_file = output, quiet = TRUE, envir = new.env()))
  } else {
    suppressWarnings(knitr::knit(file, output, quiet = TRUE, envir = new.env()))
  }

  readLines(output) |>
    paste0(collapse = "\n") |>
    cat()
}

test_that("Snapshot test of knitr", {
  expect_snapshot(.knit_file("dataframe.Rmd"), cran = TRUE)
  withr::with_options(
    new = list("polars.df_print" = "kable"),
    expect_snapshot(.knit_file("dataframe.Rmd"), cran = TRUE)
  )
  expect_snapshot(.knit_file("dataframe.Rmd", use = "rmarkdown"), cran = TRUE)
  withr::with_envvar(
    new = c("POLARS_FMT_TABLE_HIDE_COLUMN_DATA_TYPES" = "1"),
    expect_snapshot(.knit_file("dataframe.Rmd", use = "rmarkdown"), cran = TRUE)
  )
})
