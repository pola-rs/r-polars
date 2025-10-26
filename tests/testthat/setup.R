# Ensure running snapshot tests on GitHub Actions CI
if (identical(Sys.getenv("GITHUB_ACTIONS"), "true")) {
  withr::local_envvar(
    list(NOT_CRAN = "true"),
    .local_envir = teardown_env()
  )
}

# Set up for mirai tests
if (rlang::is_installed("mirai")) {
  mirai::daemons(0)
  mirai::daemons(1, output = TRUE)
  withr::defer(mirai::daemons(0), teardown_env())

  # Ensure load the package even if not installed
  mirai::everywhere({
    if (!rlang::is_installed("polars")) pkgload::load_all()
  })
}

# Set up for reticulate tests
if (
  rlang::is_installed("reticulate", version = "1.43.0") &&
    (identical(Sys.getenv("NOT_CRAN"), "true") || !nzchar(Sys.getenv("MY_UNIVERSE")))
) {
  withr::local_envvar(
    list(UV_PRERELEASE = "allow"),
    .local_envir = teardown_env()
  )
  reticulate::py_require(sprintf("polars==%s", PY_VERSION))
  reticulate::py_require("nanoarrow")
  # Required Python Polars may not be installed, so wrap in try()
  try(reticulate::py_config(), silent = TRUE)
}
