patrick::with_parameters_test_that(
  "knitr_print by {pkg} with polars.df_knitr_print = {rlang::quo_text(df_knitr_print)}, POLARS_FMT_MAX_COLS = {rlang::quo_text(fmt_max_envvars[1])}, POLARS_FMT_MAX_ROWS = {rlang::quo_text(fmt_max_envvars[2])}", # nolint: line_length_linter
  .cases = {
    skip_if_not_installed("knitr")
    skip_if_not_installed("rmarkdown")
    skip_if_not_installed("nycflights13")

    expand.grid(
      pkg = c("knitr", "rmarkdown"),
      df_knitr_print = list(NULL, "html", "default"),
      fmt_max_envvars = list(NULL, c("5", "5")),
      stringsAsFactors = FALSE
    ) |>
      tibble::as_tibble()
  },
  code = {
    withr::with_envvar(
      new = list(
        POLARS_FMT_MAX_COLS = fmt_max_envvars[1],
        POLARS_FMT_MAX_ROWS = fmt_max_envvars[2]
      ),
      {
        withr::with_options(
          new = list(polars.df_knitr_print = df_knitr_print),
          expect_snapshot(read_rendered_lines(test_path("files", "rmarkdown.Rmd"), use = pkg))
        )
      }
    )
  }
)
