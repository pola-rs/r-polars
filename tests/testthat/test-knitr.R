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
  skip_if(!requireNamespace("knitr", quietly = TRUE))
  skip_if(!requireNamespace("pillar", quietly = TRUE))

  expect_snapshot(.knit_file("dataframe.Rmd"), cran = TRUE)
  withr::with_options(
    new = list("polars.df_print" = "html"),
    expect_snapshot(.knit_file("dataframe.Rmd"), cran = TRUE)
  )
  expect_snapshot(.knit_file("dataframe.Rmd", use = "rmarkdown"), cran = TRUE)
  withr::with_options(
    new = list("polars.df_print" = "default"),
    expect_snapshot(.knit_file("dataframe.Rmd", use = "rmarkdown"), cran = TRUE)
  )
  expect_snapshot(.knit_file("flights.Rmd"), cran = TRUE)
})

test_that("to_html_table", {
  expect_snapshot(to_html_table(mtcars, 3, 3), cran = TRUE)
  expect_snapshot(to_html_table(mtcars), cran = TRUE)
})
