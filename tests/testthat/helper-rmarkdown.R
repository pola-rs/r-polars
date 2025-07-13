read_rendered_lines <- function(file_name, use = c("knitr", "rmarkdown")) {
  use <- arg_match0(use, c("knitr", "rmarkdown"))

  file <- file.path(file_name)
  outfile <- withr::local_tempfile(fileext = ".md")

  if (use == "rmarkdown") {
    skip_if_not_installed("rmarkdown")
    suppressWarnings(rmarkdown::render(
      file,
      output_file = outfile,
      quiet = TRUE,
      envir = new.env()
    ))
  } else {
    skip_if_not_installed("knitr")
    suppressWarnings(knitr::knit(file, outfile, quiet = TRUE, envir = new.env()))
  }

  readLines(outfile) |>
    paste0(collapse = "\n") |>
    cat()
}
