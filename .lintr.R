linters <- linters_with_defaults(
  line_length_linter(100L),
  object_name_linter = object_name_linter(
    styles = c("snake_case", "symbols", "SNAKE_CASE", "CamelCase"),
    regexes = c("^.*__.*", "^_.*")
  ),
  commented_code_linter = NULL # TODO: remove commented code
)
exclusions <- as.list(
  c(
    "R/000-wrappers.R",
    "R/001-wrappers.R",
    fs::dir_ls("R", glob = "**/import-standalone-*.R") |>
      rlang::set_names(NULL)
  )
)
cache_directory <- ".cache/R/lintr"
